import SwiftUI

struct ReceiveVoiceView: View {
    @State private var viewModel = ReceiveVoiceViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                ReceiveIdleView(viewModel: viewModel)
            case .loading:
                ReceiveLoadingView()
            case .ready:
                ReceiveReadyView(viewModel: viewModel)
            case .playing:
                ReceivePlayingView(viewModel: viewModel)
            case .finished:
                ReceiveFinishedView(viewModel: viewModel)
            case .empty:
                ReceiveEmptyView(viewModel: viewModel)
            }
        }
        .navigationTitle("声を受け取る")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "エラー",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct ReceiveIdleView: View {
    let viewModel: ReceiveVoiceViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: "ear.fill")
                .font(.system(size: 100))
                .foregroundStyle(.tint)
            Text("ボタンを押すと\n誰かの声が届きます")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                Task { await viewModel.fetchRandomVoice() }
            } label: {
                Label("声を受け取る", systemImage: "ear.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

private struct ReceiveLoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("探しています…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

private struct ReceiveReadyView: View {
    let viewModel: ReceiveVoiceViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.tint)
            Text("声が届いています")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            VStack(spacing: 12) {
                Button {
                    viewModel.startPlayback()
                } label: {
                    Label("再生する", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                Button("別の声を受け取る") {
                    Task { await viewModel.fetchRandomVoice() }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

private struct ReceivePlayingView: View {
    let viewModel: ReceiveVoiceViewModel
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isPulsing ? 1.18 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isPulsing)
                Image(systemName: "ear.fill")
                    .font(.system(size: 48))
            }
            .onAppear { isPulsing = true }
            WaveformView(samples: viewModel.waveformSamples, color: .accentColor)
                .frame(height: 64)
            Text("再生中…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                viewModel.stopPlayback()
            } label: {
                Label("停止", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

private struct ReceiveFinishedView: View {
    let viewModel: ReceiveVoiceViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.tint)
            VStack(spacing: 8) {
                Text("声が届きました")
                    .font(.headline)
                Text("誰かの想いを受け取りました")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 12) {
                Button {
                    Task { await viewModel.fetchRandomVoice() }
                } label: {
                    Label("もう一度受け取る", systemImage: "ear.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                Button("最初に戻る") {
                    viewModel.reset()
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

private struct ReceiveEmptyView: View {
    let viewModel: ReceiveVoiceViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("まだ声が届いていません")
                    .font(.headline)
                Text("誰かが声を届けるのを待ちましょう")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button {
                viewModel.reset()
            } label: {
                Label("戻る", systemImage: "arrow.left")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .padding(.horizontal)
    }
}
