import AVFoundation

final class AudioService: @unchecked Sendable {
    private var audioEngine: AVAudioEngine?
    private var isRunning = false

    func startCapture() -> AsyncStream<AVAudioPCMBuffer> {
        AsyncStream { continuation in
            let engine = AVAudioEngine()
            self.audioEngine = engine

            let inputNode = engine.inputNode
            let format = inputNode.outputFormat(forBus: 0)

            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                nonisolated(unsafe) let buf = buffer
                continuation.yield(buf)
            }

            do {
                try engine.start()
                self.isRunning = true
                continuation.onTermination = { @Sendable [weak self] _ in
                    self?.stopCapture()
                }
            } catch {
                continuation.finish()
            }
        }
    }

    func stopCapture() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isRunning = false
    }
}
