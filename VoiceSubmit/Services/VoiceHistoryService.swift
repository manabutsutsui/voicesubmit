import Foundation

final class VoiceHistoryService {
    static let shared = VoiceHistoryService()

    private let key = "voiceHistory"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func addSent(storagePath: String) {
        add(VoiceRecord(id: UUID(), storagePath: storagePath, createdAt: Date(), kind: .sent))
    }

    func addReceived(storagePath: String) {
        add(VoiceRecord(id: UUID(), storagePath: storagePath, createdAt: Date(), kind: .received))
    }

    func load() -> [VoiceRecord] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let records = try? decoder.decode([VoiceRecord].self, from: data)
        else { return [] }
        return records.sorted { $0.createdAt > $1.createdAt }
    }

    private func add(_ record: VoiceRecord) {
        var records = load()
        records.append(record)
        if let data = try? encoder.encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
