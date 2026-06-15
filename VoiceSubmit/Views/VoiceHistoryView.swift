import SwiftUI

struct VoiceHistoryView: View {
    @State private var viewModel = VoiceHistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $viewModel.filter) {
                    Text("送った声").tag(VoiceRecord.Kind.sent)
                    Text("受け取った声").tag(VoiceRecord.Kind.received)
                }
                .pickerStyle(.segmented)
                .padding()

                if case .error(let message) = viewModel.playState {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                let records = viewModel.filteredRecords
                if records.isEmpty {
                    emptyView
                } else {
                    List(records) { record in
                        VoiceHistoryRow(
                            record: record,
                            playState: viewModel.playState,
                            onPlay: { viewModel.play(record: record) },
                            onStop: { viewModel.stop() }
                        )
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("履歴")
            .onAppear { viewModel.load() }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: viewModel.filter == .sent ? "mic.slash" : "ear.trianglebadge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.quaternary)
            Text("まだ記録がありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(viewModel.filter == .sent
                 ? "声を届けると、ここに履歴が残ります"
                 : "声を受け取ると、ここに履歴が残ります")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

private struct VoiceHistoryRow: View {
    let record: VoiceRecord
    let playState: VoiceHistoryPlayState
    let onPlay: () -> Void
    let onStop: () -> Void

    private var isLoading: Bool {
        if case .loading(let id) = playState, id == record.id { return true }
        return false
    }

    private var isPlaying: Bool {
        if case .playing(let id) = playState, id == record.id { return true }
        return false
    }

    var body: some View {
        HStack(spacing: 16) {
            Button {
                if isPlaying {
                    onStop()
                } else {
                    onPlay()
                }
            } label: {
                Group {
                    if isLoading {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.createdAt, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(record.createdAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VoiceHistoryView()
}
