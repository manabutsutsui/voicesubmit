import FirebaseFirestore
import FirebaseStorage
import Foundation

enum RecordingState: Equatable {
    case idle
    case requesting
    case recording
    case reviewing
    case playing
    case uploading(progress: Double)
    case denied
}

@Observable
final class AudioRecorderViewModel {
    var state: RecordingState = .idle
    var elapsedTime: TimeInterval = 0
    var waveformSamples: [Float] = []
    var errorMessage: String?
    var showSendSuccessAlert = false

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
        guard let localURL = service.recordedURL else { return }
        let storageRef = Storage.storage()
            .reference()
            .child("voices/\(UUID().uuidString).m4a")

        let uploadTask = storageRef.putFile(from: localURL, metadata: nil)

        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let self, let progress = snapshot.progress else { return }
            let fraction = progress.totalUnitCount > 0
                ? Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                : 0
            self.state = .uploading(progress: fraction)
        }

        uploadTask.observe(.success) { [weak self] _ in
            guard let self else { return }
            Firestore.firestore().collection("voices").addDocument(data: [
                "storagePath": storageRef.fullPath,
                "createdAt": Timestamp()
            ])
            VoiceHistoryService.shared.addSent(storagePath: storageRef.fullPath)
            discardRecording()
            showSendSuccessAlert = true
        }

        uploadTask.observe(.failure) { [weak self] snapshot in
            guard let self else { return }
            errorMessage = snapshot.error?.localizedDescription ?? "アップロードに失敗しました"
            state = .reviewing
        }
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
