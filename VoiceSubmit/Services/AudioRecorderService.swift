import AVFoundation

final class AudioRecorderService: NSObject {
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private(set) var recordedURL: URL?

    var onRecordingFinished: ((Bool) -> Void)?
    var onPlaybackFinished: (() -> Void)?

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func startRecording() throws -> URL {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try session.setActive(true)

        let url = Self.newRecordingURL()
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let newRecorder = try AVAudioRecorder(url: url, settings: settings)
        newRecorder.isMeteringEnabled = true
        newRecorder.delegate = self
        newRecorder.record()
        recorder = newRecorder
        recordedURL = url
        return url
    }

    func currentRecordingLevel() -> Float {
        guard let recorder, recorder.isRecording else { return 0 }
        recorder.updateMeters()
        return Self.normalizedPower(recorder.averagePower(forChannel: 0))
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }

    func startPlayback() throws {
        guard let url = recordedURL else { return }
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        let newPlayer = try AVAudioPlayer(contentsOf: url)
        newPlayer.isMeteringEnabled = true
        newPlayer.delegate = self
        newPlayer.play()
        player = newPlayer
    }

    func currentPlaybackLevel() -> Float {
        guard let player, player.isPlaying else { return 0 }
        player.updateMeters()
        return Self.normalizedPower(player.averagePower(forChannel: 0))
    }

    func stopPlayback() {
        player?.stop()
        player = nil
    }

    func discardRecording() {
        stopPlayback()
        if let url = recordedURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordedURL = nil
    }

    private static func normalizedPower(_ dBValue: Float) -> Float {
        let minDb: Float = -50
        guard dBValue.isFinite else { return 0 }
        if dBValue < minDb { return 0 }
        if dBValue >= 0 { return 1 }
        return (dBValue - minDb) / -minDb
    }

    private static func newRecordingURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("voice_\(Date().timeIntervalSince1970).m4a")
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        MainActor.assumeIsolated {
            onRecordingFinished?(flag)
        }
    }
}

extension AudioRecorderService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        MainActor.assumeIsolated {
            onPlaybackFinished?()
        }
    }
}
