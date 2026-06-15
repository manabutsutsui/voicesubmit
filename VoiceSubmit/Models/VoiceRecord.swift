import Foundation

struct VoiceRecord: Codable, Identifiable {
    let id: UUID
    let storagePath: String
    let createdAt: Date
    let kind: Kind
    var title: String?

    enum Kind: String, Codable {
        case sent
        case received
    }
}
