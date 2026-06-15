import FirebaseFirestore
import Foundation

enum ReceiveVoiceState: Equatable {
    case idle
    case loading
    case ready
    case playing
    case finished
    case empty
}

@Observable
final class ReceiveVoiceViewModel {
    var state: ReceiveVoiceState = .idle
    var errorMessage: String?
    var waveformSamples: [Float] = []

    private let service = VoicePlayerService()
    private var meterTimer: Timer?

    private let sampleInterval: TimeInterval = 0.05
    private let maxSamples = 60

    init() {
        service.onPlaybackFinished = { [weak self] in
            guard let self else { return }
            stopMeterTimer()
            state = .finished
        }
    }

    func fetchRandomVoice() async {
        state = .loading
        waveformSamples = []

        do {
            let snapshot = try await Firestore.firestore()
                .collection("voices")
                .getDocuments()

            let docs = snapshot.documents
            guard !docs.isEmpty else {
                state = .empty
                return
            }

            let randomDoc = docs.randomElement()!
            guard let storagePath = randomDoc.data()["storagePath"] as? String else {
                errorMessage = "データの形式が正しくありません"
                state = .idle
                return
            }

            service.cleanup()
            try await service.downloadAndPrepare(storagePath: storagePath)
            state = .ready
        } catch {
            errorMessage = error.localizedDescription
            state = .idle
        }
    }

    func startPlayback() {
        do {
            try service.play()
            state = .playing
            waveformSamples = []
            startMeterTimer()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopPlayback() {
        stopMeterTimer()
        service.stop()
        state = .finished
    }

    func reset() {
        stopMeterTimer()
        service.cleanup()
        waveformSamples = []
        errorMessage = nil
        state = .idle
    }

    // MARK: - Private

    private func startMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) {
            [weak self] _ in
            guard let self else { return }
            appendSample(service.currentLevel())
        }
    }

    private func stopMeterTimer() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func appendSample(_ value: Float) {
        waveformSamples.append(value)
        if waveformSamples.count > maxSamples {
            waveformSamples.removeFirst()
        }
    }
}
