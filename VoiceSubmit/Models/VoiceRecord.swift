import Foundation

struct VoiceRecord: Codable, Identifiable {
    let id: UUID
    let storagePath: String
    let createdAt: Date

    enum Kind: String, Codable {
        case sent
        case received
    }

    let kind: Kind
}
