import SwiftUI

struct ReceiveVoiceView: View {
    var body: some View {
        ContentUnavailableView(
            "準備中",
            systemImage: "ear.fill",
            description: Text("声を受け取る機能は近日追加予定です")
        )
        .navigationTitle("声を受け取る")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReceiveVoiceView()
    }
}
