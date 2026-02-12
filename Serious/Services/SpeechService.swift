import Speech
import AVFoundation

struct TranscriptionResult: Sendable {
    let text: String
    let isFinal: Bool
    let words: [String]
    let timestamp: Date

    init(text: String, isFinal: Bool = false) {
        self.text = text
        self.isFinal = isFinal
        self.words = text.split(separator: /\s+/).map(String.init)
        self.timestamp = Date()
    }
}

protocol SpeechServiceProtocol: Sendable {
    func startTranscription(locale: String) -> AsyncStream<TranscriptionResult>
    func stopTranscription() async
}

final class LegacySpeechService: SpeechServiceProtocol, @unchecked Sendable {
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var continuation: AsyncStream<TranscriptionResult>.Continuation?
    private var sessionRestartTask: Task<Void, Never>?

    static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startTranscription(locale: String) -> AsyncStream<TranscriptionResult> {
        AsyncStream { continuation in
            self.continuation = continuation
            let loc = Locale(identifier: locale)
            self.recognizer = SFSpeechRecognizer(locale: loc)
            startSession()

            continuation.onTermination = { @Sendable [weak self] _ in
                guard let self else { return }
                Task { await self.stopTranscription() }
            }
        }
    }

    private func startSession() {
        guard let recognizer else {
            continuation?.finish()
            return
        }

        let audioEngine = AVAudioEngine()
        self.audioEngine = audioEngine

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }
        self.recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        guard format.sampleRate > 0, format.channelCount > 0 else {
            continuation?.finish()
            return
        }

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        do {
            try audioEngine.start()
        } catch {
            audioEngine.inputNode.removeTap(onBus: 0)
            continuation?.finish()
            return
        }

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                let transcription = TranscriptionResult(
                    text: result.bestTranscription.formattedString,
                    isFinal: result.isFinal
                )
                self.continuation?.yield(transcription)
            }

            if error != nil || (result?.isFinal == true) {
                self.restartSessionIfNeeded()
            }
        }

        scheduleSessionRestart()
    }

    private func scheduleSessionRestart() {
        sessionRestartTask?.cancel()
        sessionRestartTask = Task {
            try? await Task.sleep(for: .seconds(Constants.sfSpeechSessionLimit))
            guard !Task.isCancelled else { return }
            restartSessionIfNeeded()
        }
    }

    private func restartSessionIfNeeded() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        guard continuation != nil else { return }
        startSession()
    }

    func stopTranscription() async {
        sessionRestartTask?.cancel()
        sessionRestartTask = nil
        continuation?.finish()
        continuation = nil
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

@available(macOS 26.0, *)
final class ModernSpeechService: SpeechServiceProtocol, @unchecked Sendable {
    private var analyzerTask: Task<Void, Never>?
    private var analyzer: SpeechAnalyzer?

    func startTranscription(locale: String) -> AsyncStream<TranscriptionResult> {
        AsyncStream { continuation in
            analyzerTask = Task {
                do {
                    let transcriber = SpeechTranscriber(
                        locale: Locale(identifier: locale),
                        preset: .progressiveTranscription
                    )
                    let analyzer = SpeechAnalyzer(modules: [transcriber])
                    self.analyzer = analyzer

                    let audioEngine = AVAudioEngine()
                    let inputNode = audioEngine.inputNode
                    let format = inputNode.outputFormat(forBus: 0)

                    guard format.sampleRate > 0, format.channelCount > 0 else {
                        continuation.finish()
                        return
                    }

                    let audioStream = AsyncStream<AnalyzerInput> { audioContinuation in
                        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                            audioContinuation.yield(AnalyzerInput(buffer: buffer))
                        }
                        nonisolated(unsafe) let node = inputNode
                        nonisolated(unsafe) let engine = audioEngine
                        audioContinuation.onTermination = { @Sendable _ in
                            node.removeTap(onBus: 0)
                            engine.stop()
                        }
                    }

                    try audioEngine.start()
                    try await analyzer.start(inputSequence: audioStream)

                    for try await result in transcriber.results {
                        let text = String(result.text.characters)
                        let transcriptionResult = TranscriptionResult(text: text)
                        continuation.yield(transcriptionResult)
                    }
                } catch {
                    // Fall through to finish
                }
                continuation.finish()
            }

            continuation.onTermination = { @Sendable [weak self] _ in
                self?.analyzerTask?.cancel()
                Task {
                    await self?.analyzer?.cancelAndFinishNow()
                }
            }
        }
    }

    func stopTranscription() async {
        analyzerTask?.cancel()
        await analyzer?.cancelAndFinishNow()
        analyzer = nil
        analyzerTask = nil
    }
}

enum SpeechServiceFactory {
    static func create(locale: String) async -> any SpeechServiceProtocol {
        if #available(macOS 26.0, *), SpeechTranscriber.isAvailable {
            let transcriber = SpeechTranscriber(
                locale: Locale(identifier: locale),
                preset: .progressiveTranscription
            )
            let status = await AssetInventory.status(forModules: [transcriber])
            if status >= .installed {
                return ModernSpeechService()
            }
        }
        return LegacySpeechService()
    }
}
