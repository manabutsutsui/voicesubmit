import SwiftUI

struct SendVoiceView: View {
    @State private var viewModel = AudioRecorderViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .requesting:
                IdleView(viewModel: viewModel)
            case .recording:
                RecordingView(viewModel: viewModel)
            case .reviewing, .playing, .uploading:
                ReviewingView(viewModel: viewModel)
            case .denied:
                DeniedView()
            }
        }
        .navigationTitle("声を届ける")
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
        .alert(
            "送信完了",
            isPresented: Binding(
                get: { viewModel.showSendSuccessAlert },
                set: { viewModel.showSendSuccessAlert = $0 }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("声を送りました。")
        }
    }
}

private struct IdleView: View {
    let viewModel: AudioRecorderViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Image(systemName: "mic.fill")
                .font(.system(size: 100))
            Text("マイクボタンを押して\n録音を開始してください")
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                Task { await viewModel.startRecording() }
            } label: {
                Label("録音を開始", systemImage: "mic.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.state == .requesting)
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
}

private struct RecordingView: View {
    let viewModel: AudioRecorderViewModel
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
                Image(systemName: "mic.fill")
                    .font(.system(size: 48))
            }
            .onAppear { isPulsing = true }
            Text(viewModel.elapsedTime.mmss)
                .font(.system(size: 48, weight: .thin, design: .monospaced))
            WaveformView(samples: viewModel.waveformSamples, color: .accentColor)
                .frame(height: 64)
            Text("録音中...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                viewModel.stopRecording()
            } label: {
                Label("録音を停止", systemImage: "stop.fill")
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

private struct ReviewingView: View {
    let viewModel: AudioRecorderViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
            Text(viewModel.elapsedTime.mmss)
                .font(.system(size: 48, weight: .thin, design: .monospaced))
            WaveformView(
                samples: viewModel.waveformSamples,
                color: .accentColor
            )
            .frame(height: 64)
            .animation(.easeInOut(duration: 0.1), value: viewModel.waveformSamples.count)
            HStack {
                Image(systemName: "tag")
                    .foregroundStyle(.secondary)
                TextField("タイトル（任意）", text: Binding(
                    get: { viewModel.title },
                    set: { viewModel.title = $0 }
                ))
                .autocorrectionDisabled()
                .submitLabel(.done)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            Spacer()
            VStack(spacing: 12) {
                if case .uploading(let progress) = viewModel.state {
                    ProgressView(value: progress)
                        .padding(.horizontal)
                    Text("\(Int(progress * 100))% アップロード中...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if viewModel.state == .playing {
                    Button {
                        viewModel.stopPlayback()
                    } label: {
                        Label("停止", systemImage: "stop.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        viewModel.startPlayback()
                    } label: {
                        Label("再生して確認", systemImage: "play.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
                Button {
                    viewModel.onSend()
                } label: {
                    Label("送信する", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    {
                        if case .uploading = viewModel.state { return true }
                        return false
                    }())
                Button("録り直す") {
                    viewModel.discardRecording()
                }
                .padding(.top, 4)
                .disabled(
                    {
                        if case .uploading = viewModel.state { return true }
                        return false
                    }())
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
}

private struct DeniedView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("マイクの使用が許可されていません")
                    .font(.headline)
                Text("設定アプリからマイクへのアクセスを許可してください")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button("設定を開く") {
                if let url = URL(string: "app-settings:") {
                    openURL(url)
                }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}

struct WaveformView: View {
    let samples: [Float]
    var color: Color = .accentColor

    private let barWidth: CGFloat = 3
    private let barSpacing: CGFloat = 2
    private let minBarHeightFraction: CGFloat = 0.05

    var body: some View {
        Canvas { context, size in
            let unitWidth = barWidth + barSpacing
            let visibleCount = Int(size.width / unitWidth)
            let displaySamples = samples.suffix(visibleCount)
            let startIndex = (visibleCount - displaySamples.count) / 2

            for (offset, sample) in displaySamples.enumerated() {
                let i = startIndex + offset
                let x = CGFloat(i) * unitWidth
                let fraction = CGFloat(max(sample, Float(minBarHeightFraction)))
                let barHeight = fraction * size.height
                let y = (size.height - barHeight) / 2
                let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                let path = Path(roundedRect: rect, cornerRadius: barWidth / 2)
                context.fill(path, with: .color(color))
            }
        }
    }
}

extension TimeInterval {
    fileprivate var mmss: String {
        let total = Int(self)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
