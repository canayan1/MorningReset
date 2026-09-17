import SwiftUI
import AVFoundation
import CoreImage
import Combine

// MARK: - CameraSession
//
// Front-camera capture for the Morning Energy Read. Runs Core Image smile
// detection on the live preview frames and auto-captures the moment it sees a
// sustained smile (with a manual shutter as fallback). Everything stays on the
// device — frames are analysed in memory and never written out or sent anywhere.
//
// Smile detection is the part that has to be forgiving rather than clever. It
// runs against a person who has just woken up, in whatever light the bedroom
// has, and the failure it must never have is holding out for a smile that is
// already there. So: the accurate detector rather than the fast one, a face
// that only has to smile in two of the last three looks, and — in the screens
// that use this — a shutter of their own if it still hasn't seen one.

final class CameraSession: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    let session = AVCaptureSession()

    @Published var available = true
    @Published var smiling = false
    /// Whether a face is in frame at all. The difference matters to the person
    /// holding the phone: "I can't see you" and "I can see you, keep going"
    /// are different problems and only one of them is theirs to fix.
    @Published var seesFace = false

    /// Called once, on the main thread, with the captured selfie.
    var onCapture: ((UIImage) -> Void)?

    private let sessionQueue = DispatchQueue(label: "energy.camera.session")
    private let videoQueue = DispatchQueue(label: "energy.camera.video")
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    /// High accuracy, not low.
    ///
    /// `hasSmile` is a different question from "is there a face", and the low
    /// setting answers the first one badly: it finds the face and then reports
    /// no smile at someone who is grinning at the phone. The cost is paid back
    /// by only looking at every third frame, and at a quarter of the width.
    private lazy var detector = CIDetector(
        ofType: CIDetectorTypeFace,
        context: ciContext,
        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh,
                  CIDetectorMinFeatureSize: 0.15]
    )

    private var frameCount = 0
    /// The last few answers, rather than a run of consecutive ones. A smile
    /// detector blinks: it drops a frame in the middle of a perfectly good
    /// smile, and a strictly consecutive streak starts again from nothing
    /// every time it does — which is how someone ends up smiling at a phone
    /// that never takes the picture.
    private var recentSmiles: [Bool] = []
    /// When the current smile began. The capture waits for it to be *held*,
    /// because the difference between a smile and a twitch of the mouth is
    /// how long it lasts — and a morning that snaps at the first flicker
    /// hasn't really asked anyone to smile.
    private var smileBegan: Date?
    private var holdSeconds: Double = 0
    private var wantsCapture = false
    private var captured = false
    private var autoCapture = true

    func configureAndStart() {
        // Starting again means starting again. Without this the second run is
        // deaf: `captured` stays true from the first capture and every frame
        // returns at the guard, so "Read again" restarts the camera onto a
        // session that can no longer produce anything.
        captured = false
        wantsCapture = false
        recentSmiles.removeAll()
        smileBegan = nil
        frameCount = 0

        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.configure()
            guard !self.session.inputs.isEmpty else {
                DispatchQueue.main.async { self.available = false }
                return
            }
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    /// Manual shutter — captures the next frame.
    func capture() { wantsCapture = true }

    func setAutoCapture(_ on: Bool) { autoCapture = on }

    /// How long a smile has to last before it is taken. Zero is the old
    /// behaviour: the first look that qualifies wins.
    func setSmileHold(_ seconds: Double) { holdSeconds = seconds }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }

        if let conn = output.connection(with: .video) {
            if conn.isVideoRotationAngleSupported(90) { conn.videoRotationAngle = 90 }
            if conn.isVideoMirroringSupported {
                conn.automaticallyAdjustsVideoMirroring = false
                conn.isVideoMirrored = true
            }
        }
        session.commitConfiguration()
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard !captured, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        frameCount += 1
        if frameCount % 3 == 0 {
            // Detection runs on a quarter-width copy: a face fills most of the
            // circle, so the detail thrown away is not the detail this needs,
            // and the accuracy saved by the smaller image is spent on the
            // setting that actually finds smiles.
            let small = ciImage.transformed(by: CGAffineTransform(scaleX: 0.25, y: 0.25))
            let faces = detector?.features(in: small, options: [
                CIDetectorSmile: true,
                CIDetectorEyeBlink: false,
                // Say which way up it is rather than leaving it to be guessed.
                // The connection already rotates the buffer upright, and a face
                // detector handed a sideways frame simply finds nothing.
                CIDetectorImageOrientation: 1
            ]) as? [CIFaceFeature] ?? []

            let face = faces.max { $0.bounds.width < $1.bounds.width }
            let isSmiling = face?.hasSmile ?? false
            let hasFace = face != nil
            DispatchQueue.main.async {
                if self.smiling != isSmiling { self.smiling = isSmiling }
                if self.seesFace != hasFace { self.seesFace = hasFace }
            }

            recentSmiles.append(isSmiling)
            if recentSmiles.count > 3 { recentSmiles.removeFirst() }

            // Two of the last three looks is what counts as smiling now; a
            // single dropped frame in the middle of a held smile must not
            // reset the clock.
            let smilingNow = recentSmiles.filter({ $0 }).count >= 2
            if smilingNow {
                if smileBegan == nil { smileBegan = Date() }
            } else {
                smileBegan = nil
            }
            if autoCapture, let began = smileBegan, Date().timeIntervalSince(began) >= holdSeconds {
                wantsCapture = true
            }
        }

        if wantsCapture {
            captured = true
            if let cg = ciContext.createCGImage(ciImage, from: ciImage.extent) {
                let image = UIImage(cgImage: cg)
                DispatchQueue.main.async { self.onCapture?(image) }
            }
            stop()
        }
    }
}

// MARK: - CameraPreview

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
