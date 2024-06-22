import SwiftUI
import QuartzCore

class FrameRateViewModel: ObservableObject {
    @Published var frameRate: Double = 0
    
    private var displayLink: CADisplayLink?

    init() {}

    func startMonitoring() {
        startDisplayLink()
    }

    func stopMonitoring() {
        stopDisplayLink()
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrameRate))
        displayLink?.add(to: .main, forMode: .default)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateFrameRate(displayLink: CADisplayLink) {
        frameRate = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
    }

    deinit {
        stopDisplayLink()
    }
}
