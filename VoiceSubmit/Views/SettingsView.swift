import SwiftUI

struct SettingsView: View {
    private var appDisplayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ""
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0.0"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("アプリ情報") {
                    LabeledContent("バージョン", value: appVersion)
                    LabeledContent("アプリ名", value: appDisplayName)
                }
            }
            .navigationTitle("設定")
        }
    }
}