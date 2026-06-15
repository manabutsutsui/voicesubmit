import AVFoundation
import FirebaseStorage

final class VoicePlayerService: NSObject {
    private var player: AVAudioPlayer?
    private var localURL: URL?

    var onPlaybackFinished: (() -> Void)?

    func downloadAndPrepare(storagePath: String) async throws {
        let ref = Storage.storage().reference().child(storagePath)
        let downloadURL = try await ref.downloadURL()

        let (tempURL, _) = try await URLSession.shared.download(from: downloadURL)
        let destURL = Self.localCacheURL(for: storagePath)
        try? FileManager.default.removeItem(at: destURL)
        try FileManager.default.moveItem(at: tempURL, to: destURL)

        localURL = destURL
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)

        let newPlayer = try AVAudioPlayer(contentsOf: destURL)
        newPlayer.isMeteringEnabled = true
        newPlayer.delegate = self
        newPlayer.prepareToPlay()
        player = newPlayer
    }

    func play() throws {
        guard let player else { return }
        player.play()
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func currentLevel() -> Float {
        guard let player, player.isPlaying else { return 0 }
        player.updateMeters()
        return Self.normalizedPower(player.averagePower(forChannel: 0))
    }

    func cleanup() {
        stop()
        if let url = localURL {
            try? FileManager.default.removeItem(at: url)
        }
        localURL = nil
    }

    private static func normalizedPower(_ dBValue: Float) -> Float {
        let minDb: Float = -50
        guard dBValue.isFinite else { return 0 }
        if dBValue < minDb { return 0 }
        if dBValue >= 0 { return 1 }
        return (dBValue - minDb) / -minDb
    }

    private static func localCacheURL(for storagePath: String) -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let filename = storagePath.replacingOccurrences(of: "/", with: "_")
        return caches.appendingPathComponent(filename)
    }
}

extension VoicePlayerService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        MainActor.assumeIsolated {
            onPlaybackFinished?()
        }
    }
}
