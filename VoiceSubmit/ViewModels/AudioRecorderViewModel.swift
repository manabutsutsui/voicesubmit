import Foundation

enum RecordingState {
    case idle
    case requesting
    case recording
    case reviewing
    case playing
    case denied
}

@Observable
final class AudioRecorderViewModel {
    var state: RecordingState = .idle
    var elapsedTime: TimeInterval = 0
    var waveformSamples: [Float] = []
    var errorMessage: String?

    private let service = AudioRecorderService()
    private var meterTimer: Timer?
    private var recordingStartDate: Date?

    private let sampleInterval: TimeInterval = 0.05
    private let maxSamples = 60

    init() {
        service.onRecordingFinished = { [weak self] success in
            guard let self else { return }
            stopMeterTimer()
            if success {
                state = .reviewing
            } else {
                state = .idle
                errorMessage = "録音に失敗しました"
            }
        }
        service.onPlaybackFinished = { [weak self] in
            guard let self else { return }
            stopMeterTimer()
            state = .reviewing
        }
    }

    func startRecording() async {
        state = .requesting
        let granted = await service.requestPermission()
        guard granted else {
            state = .denied
            return
        }
        do {
            _ = try service.startRecording()
            state = .recording
            elapsedTime = 0
            waveformSamples = []
            recordingStartDate = Date()
            startMeterTimer(sampling: { [weak self] in
                guard let self else { return }
                elapsedTime = Date().timeIntervalSince(recordingStartDate ?? Date())
                appendSample(service.currentRecordingLevel())
            })
        } catch {
            state = .idle
            errorMessage = error.localizedDescription
        }
    }

    func stopRecording() {
        service.stopRecording()
    }

    func startPlayback() {
        do {
            try service.startPlayback()
            state = .playing
            waveformSamples = []
            startMeterTimer(sampling: { [weak self] in
                guard let self else { return }
                appendSample(service.currentPlaybackLevel())
            })
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stopPlayback() {
        stopMeterTimer()
        service.stopPlayback()
        state = .reviewing
    }

    func discardRecording() {
        stopMeterTimer()
        service.discardRecording()
        elapsedTime = 0
        waveformSamples = []
        recordingStartDate = nil
        state = .idle
    }

    func onSend() {
        // 将来: ネットワーク送信処理をここに追加
        discardRecording()
    }

    // MARK: - Private

    private func startMeterTimer(sampling: @escaping () -> Void) {
        meterTimer?.invalidate()
        meterTimer = Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { _ in
            sampling()
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
