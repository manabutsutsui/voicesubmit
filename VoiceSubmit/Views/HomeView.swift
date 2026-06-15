import SwiftUI

struct HomeView: View {
    private var appDisplayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ""
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 8) {
                    Text(appDisplayName)
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .kerning(1.2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, Color.accentColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("その声、誰かに届け")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("知らない誰かの声を、届けたり受け取ったり")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                Spacer()
                HStack(spacing: 40) {
                    NavigationLink {
                        SendVoiceView()
                    } label: {
                        HomeRoundButton(title: "声を届ける", systemImage: "mic.fill")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ReceiveVoiceView()
                    } label: {
                        HomeRoundButton(title: "声を受け取る", systemImage: "ear.fill")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
}

private struct HomeRoundButton: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.primary, Color.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 144, height: 144)
                Image(systemName: systemImage)
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    HomeView()
}
