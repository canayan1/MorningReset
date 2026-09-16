import Foundation

// MARK: - The pulse signal
//
// Everything between a camera frame and a number, kept apart from the camera so
// it can be tested without one.
//
// The measured facts this is built on, from real iPhone captures under the
// torch: a fingertip reads red ≈ 190/255 with green and blue near zero, and the
// pulse itself is 0.2%–2% of that — three counts out of 255. Two consequences
// run through everything below. The signal has to be a *chromaticity* rather
// than a brightness, because three counts do not survive an auto-exposure step
// or the torch dimming as the phone warms. And the filter has to be flat across
// the heart-rate band, because losing a few dB loses the whole beat.

enum PulseSignal {

    /// The searched band, in beats per minute.
    static let minBPM = 40.0
    static let maxBPM = 180.0

    // MARK: - Frame to sample

    /// What one frame contributes.
    struct Sample {
        /// Hue of the frame's mean colour, 0…1. This is the analysed series:
        /// it is a ratio between channels, so it barely moves when the overall
        /// light level does — which is why the implementations that use it can
        /// run without locking exposure at all.
        let hue: Double
        /// Red as a share of all three channels. A fingertip over a lit lens is
        /// overwhelmingly red; a room, a pocket or a face is not.
        let redShare: Double
        /// Mean red, 0…1 — for the "press a little harder" and "ease off" cases.
        let red: Double
        /// Fraction of sampled pixels with red at the top of its range. A
        /// clipped channel carries no pulse at all.
        let clipped: Double
    }

    /// Hue of an RGB triple, 0…1. Undefined for grey, which is reported as 0
    /// and rejected upstream by the red-share test.
    static func hue(r: Double, g: Double, b: Double) -> Double {
        let high = max(r, g, b), low = min(r, g, b)
        let span = high - low
        guard span > 1e-9 else { return 0 }
        let h: Double
        if high == r      { h = (g - b) / span }
        else if high == g { h = 2 + (b - r) / span }
        else              { h = 4 + (r - g) / span }
        return ((h * 60).truncatingRemainder(dividingBy: 360) + 360)
            .truncatingRemainder(dividingBy: 360) / 360
    }

    /// Is a fingertip on the lens?
    ///
    /// Tested as a ratio, not an absolute level: an absolute threshold fails on
    /// darker skin, on a thicker fingertip, and on a torch the phone has dimmed
    /// because it is warm. The earlier version of this used an absolute 0.22 —
    /// about a quarter of what a real torch-lit finger reads — so it said "yes"
    /// while auto-exposure was still ramping.
    static func fingerPresent(_ s: Sample) -> Bool {
        s.redShare >= 0.5 && s.red >= 0.39
    }

    // MARK: - Filtering

    /// One biquad section.
    private struct Biquad {
        let b0, b1, b2, a1, a2: Double

        static func lowPass(cutoff: Double, sampleRate: Double) -> Biquad {
            let w = 2 * .pi * cutoff / sampleRate
            let cs = cos(w), alpha = sin(w) / (2 * 0.7071067811865476)
            let a0 = 1 + alpha
            return Biquad(b0: (1 - cs) / 2 / a0, b1: (1 - cs) / a0, b2: (1 - cs) / 2 / a0,
                          a1: -2 * cs / a0, a2: (1 - alpha) / a0)
        }

        static func highPass(cutoff: Double, sampleRate: Double) -> Biquad {
            let w = 2 * .pi * cutoff / sampleRate
            let cs = cos(w), alpha = sin(w) / (2 * 0.7071067811865476)
            let a0 = 1 + alpha
            return Biquad(b0: (1 + cs) / 2 / a0, b1: -(1 + cs) / a0, b2: (1 + cs) / 2 / a0,
                          a1: -2 * cs / a0, a2: (1 - alpha) / a0)
        }

        func apply(_ x: [Double]) -> [Double] {
            var y = [Double](repeating: 0, count: x.count)
            var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0
            for i in 0..<x.count {
                let out = b0 * x[i] + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
                x2 = x1; x1 = x[i]; y2 = y1; y1 = out
                y[i] = out
            }
            return y
        }
    }

    /// Band-pass the trace, zero-phase.
    ///
    /// The corners sit outside the searched band — 0.6 Hz is below 40 bpm and
    /// 4.6 Hz above 180 — so the band itself is flat. The previous version
    /// subtracted a 0.75-second moving average, which is a comb filter: about
    /// 3 dB down at 60 bpm and 9 dB at 40, while passing 80 and 160 at full
    /// gain. It was quietly suppressing exactly the resting rates it was for.
    ///
    /// Run forwards and then backwards so the filter adds no phase, which
    /// matters because the peak positions are what become the answer.
    static func bandpass(_ input: [Double], sampleRate: Double) -> [Double] {
        guard input.count > 12 else { return [] }
        let high = Biquad.highPass(cutoff: 0.6, sampleRate: sampleRate)
        let low  = Biquad.lowPass(cutoff: 4.6, sampleRate: sampleRate)

        // Start from the mean so the filter does not ring on the first sample.
        let mean = input.reduce(0, +) / Double(input.count)
        var x = input.map { $0 - mean }
        x = low.apply(high.apply(x))
        x = low.apply(high.apply(x.reversed())).reversed()
        return x
    }

    /// Resample onto an even grid.
    ///
    /// Frames do not arrive evenly — real captures drop several percent of them
    /// — and a lag turned into a rate by dividing by a nominal frame rate
    /// inherits every one of those gaps as an error.
    static func resample(times: [Double], values: [Double], to rate: Double) -> [Double] {
        guard times.count == values.count, times.count > 1,
              let first = times.first, let last = times.last, last > first else { return [] }
        let count = Int((last - first) * rate)
        guard count > 1 else { return [] }
        var out = [Double](repeating: 0, count: count)
        var j = 0
        for i in 0..<count {
            let t = first + Double(i) / rate
            while j + 2 < times.count, times[j + 1] < t { j += 1 }
            let span = times[j + 1] - times[j]
            let f = span > 1e-9 ? (t - times[j]) / span : 0
            out[i] = values[j] + (values[j + 1] - values[j]) * min(1, max(0, f))
        }
        return out
    }

    // MARK: - Rate

    /// Finds the beat by asking how well the trace lines up with itself.
    ///
    /// Counting peaks is the obvious way and it is fragile: a fingertip trace is
    /// full of small bumps that look like peaks, and one missed or doubled beat
    /// takes the estimate with it. Autocorrelation asks a steadier question and
    /// answers with a number between 0 and 1 that is itself a fair confidence.
    static func estimate(_ signal: [Double], sampleRate: Double) -> (bpm: Double, confidence: Double)? {
        guard signal.count > Int(sampleRate * 4) else { return nil }
        let mean = signal.reduce(0, +) / Double(signal.count)
        let x = signal.map { $0 - mean }
        guard x.contains(where: { abs($0) > 1e-12 }) else { return nil }

        let minLag = Int(sampleRate * 60 / maxBPM)
        let maxLag = Int(sampleRate * 60 / minBPM)
        guard maxLag < x.count / 2, minLag >= 1 else { return nil }

        func correlation(at lag: Int) -> Double {
            let n = x.count - lag
            var num = 0.0, a = 0.0, b = 0.0
            for i in 0..<n {
                num += x[i] * x[i + lag]
                a += x[i] * x[i]
                b += x[i + lag] * x[i + lag]
            }
            let d = (a * b).squareRoot()
            return d > 0 ? num / d : 0
        }

        var scores: [Int: Double] = [:]
        var best = (lag: 0, score: -1.0)
        for lag in minLag...maxLag {
            let c = correlation(at: lag)
            scores[lag] = c
            if c > best.score { best = (lag, c) }
        }
        guard best.lag > 0, best.score > 0.35 else { return nil }

        // A signal resembles itself at twice and three times its period, so the
        // strongest match can be a whole beat too slow. Look where a genuine
        // subharmonic would be rather than at any shorter lag scoring nearly as
        // well — near the peak that is most of them, and taking the shortest
        // reads every pulse about five percent fast.
        var lag = best.lag
        for divisor in [2, 3] {
            let candidate = Int((Double(best.lag) / Double(divisor)).rounded())
            guard candidate >= minLag else { continue }
            let slack = max(1, candidate / 10)
            let low = max(minLag, candidate - slack), high = min(maxLag, candidate + slack)
            guard low <= high,
                  let local = (low...high).max(by: { (scores[$0] ?? 0) < (scores[$1] ?? 0) }),
                  let score = scores[local], score >= best.score * 0.85 else { continue }
            lag = local
            break
        }

        // Place the lag between whole frames: at 30 Hz two of them are several
        // bpm apart at a running heart rate.
        var refined = Double(lag)
        if lag > minLag, lag < maxLag,
           let a = scores[lag - 1], let b = scores[lag], let c = scores[lag + 1] {
            let curve = a - 2 * b + c
            if abs(curve) > 1e-12 { refined += max(-0.5, min(0.5, 0.5 * (a - c) / curve)) }
        }

        let bpm = 60 * sampleRate / refined
        guard bpm >= minBPM, bpm <= maxBPM else { return nil }
        return (bpm, min(1, max(0, best.score)))
    }

    /// Do these window estimates agree closely enough to show a number?
    ///
    /// Nothing here settles because one number crossed one threshold once — a
    /// band-limited noise window autocorrelates above 0.35 often enough. It
    /// settles because consecutive windows say the same thing.
    static func agreed(_ recent: [Double], within fraction: Double = 0.06) -> Double? {
        guard recent.count >= 3 else { return nil }
        let last = Array(recent.suffix(3))
        let mean = last.reduce(0, +) / Double(last.count)
        guard mean > 0, last.allSatisfy({ abs($0 - mean) / mean <= fraction }) else { return nil }
        return mean
    }
}
