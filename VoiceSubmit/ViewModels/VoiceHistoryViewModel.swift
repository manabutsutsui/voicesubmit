import Foundation

enum VoiceHistoryPlayState: Equatable {
    case idle
    case loading(id: UUID)
    case playing(id: UUID)
    case error(String)
}

@Observable
final class VoiceHistoryViewModel {
    var filter: VoiceRecord.Kind = .sent
    var playState: VoiceHistoryPlayState = .idle
    private(set) var records: [VoiceRecord] = []

    private let historyService = VoiceHistoryService.shared
    private var playerService = VoicePlayerService()

    init() {
        playerService.onPlaybackFinished = { [weak self] in
            guard let self else { return }
            playState = .idle
        }
    }

    var filteredRecords: [VoiceRecord] {
        records.filter { $0.kind == filter }
    }

    func load() {
        records = historyService.load()
    }

    func play(record: VoiceRecord) {
        guard playState != .loading(id: record.id),
              playState != .playing(id: record.id) else { return }

        playerService.cleanup()
        playState = .loading(id: record.id)

        Task { @MainActor in
            do {
                try await playerService.downloadAndPrepare(storagePath: record.storagePath)
                try playerService.play()
                playState = .playing(id: record.id)
            } catch {
                playState = .error(error.localizedDescription)
            }
        }
    }

    func stop() {
        playerService.stop()
        playState = .idle
    }

    func delete(record: VoiceRecord) {
        if case .playing(let id) = playState, id == record.id { stop() }
        if case .loading(let id) = playState, id == record.id { stop() }
        historyService.delete(id: record.id)
        records = historyService.load()
    }

    func updateTitle(record: VoiceRecord, title: String) {
        historyService.updateTitle(id: record.id, title: title)
        records = historyService.load()
    }
}
