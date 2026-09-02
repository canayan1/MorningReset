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

final class CameraSession: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    let session = AVCaptureSession()

    @Published var available = true
    @Published var smiling = false

    /// Called once, on the main thread, with the captured selfie.
    var onCapture: ((UIImage) -> Void)?

    private let sessionQueue = DispatchQueue(label: "energy.camera.session")
    private let videoQueue = DispatchQueue(label: "energy.camera.video")
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    private lazy var detector = CIDetector(
        ofType: CIDetectorTypeFace,
        context: ciContext,
        options: [CIDetectorAccuracy: CIDetectorAccuracyLow]
    )

    private var frameCount = 0
    private var smileStreak = 0
    private var wantsCapture = false
    private var captured = false
    private var autoCapture = true

    func configureAndStart() {
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
        if frameCount % 4 == 0 {
            let faces = detector?.features(in: ciImage, options: [CIDetectorSmile: true]) as? [CIFaceFeature] ?? []
            let isSmiling = faces.contains { $0.hasSmile }
            DispatchQueue.main.async { if self.smiling != isSmiling { self.smiling = isSmiling } }
            smileStreak = isSmiling ? smileStreak + 1 : 0
            if autoCapture && smileStreak >= 2 { wantsCapture = true }
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
