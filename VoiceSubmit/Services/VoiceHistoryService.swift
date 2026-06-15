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

    func delete(id: UUID) {
        var records = load()
        records.removeAll { $0.id == id }
        save(records)
    }

    func updateTitle(id: UUID, title: String) {
        var records = load()
        if let index = records.firstIndex(where: { $0.id == id }) {
            records[index].title = title.isEmpty ? nil : title
        }
        save(records)
    }

    private func add(_ record: VoiceRecord) {
        var records = load()
        records.append(record)
        save(records)
    }

    private func save(_ records: [VoiceRecord]) {
        if let data = try? encoder.encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
