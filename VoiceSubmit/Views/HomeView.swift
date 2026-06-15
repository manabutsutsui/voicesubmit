import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 8) {
                    Text("その声、誰かに届け")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("知らない誰かの声を、届けたり受け取ったり")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                Spacer()
                VStack(spacing: 16) {
                    NavigationLink {
                        SendVoiceView()
                    } label: {
                        HomeActionButton(
                            title: "声を届ける",
                            subtitle: "あなたの声を、誰かへ",
                            systemImage: "mic.fill"
                        )
                    }
                    NavigationLink {
                        ReceiveVoiceView()
                    } label: {
                        HomeActionButton(
                            title: "声を受け取る",
                            subtitle: "誰かから届いた声を聴く",
                            systemImage: "ear.fill"
                        )
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

private struct HomeActionButton: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(.tint.opacity(0.15))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }
}

#Preview {
    HomeView()
}
