import FirebaseFirestore
import Foundation

enum ReportReason: String, CaseIterable {
    case inappropriate = "不適切なコンテンツ"
    case spam = "スパム"
    case harassment = "嫌がらせ"
    case other = "その他"
}

final class ReportService {
    private let deviceIdKey = "anonymousDeviceId"

    private var deviceId: String {
        if let stored = UserDefaults.standard.string(forKey: deviceIdKey) {
            return stored
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: deviceIdKey)
        return newId
    }

    func report(storagePath: String, reason: ReportReason) async throws {
        let data: [String: Any] = [
            "storagePath": storagePath,
            "reason": reason.rawValue,
            "reportedAt": Timestamp(date: Date()),
            "deviceId": deviceId
        ]
        try await Firestore.firestore()
            .collection("reports")
            .addDocument(data: data)
    }
}
