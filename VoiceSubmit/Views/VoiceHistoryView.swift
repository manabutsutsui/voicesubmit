import SwiftUI

struct VoiceHistoryView: View {
    @State private var viewModel = VoiceHistoryViewModel()
    @State private var editingRecord: VoiceRecord?
    @State private var deletingRecord: VoiceRecord?

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
                            onStop: { viewModel.stop() },
                            onEdit: { editingRecord = record },
                            onDelete: { deletingRecord = record }
                        )
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear { viewModel.load() }
            .sheet(item: $editingRecord) { record in
                EditTitleSheet(record: record) { newTitle in
                    viewModel.updateTitle(record: record, title: newTitle)
                }
            }
            .confirmationDialog(
                "この声を削除しますか？",
                isPresented: Binding(
                    get: { deletingRecord != nil },
                    set: { if !$0 { deletingRecord = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("削除", role: .destructive) {
                    if let record = deletingRecord {
                        viewModel.delete(record: record)
                    }
                    deletingRecord = nil
                }
                Button("キャンセル", role: .cancel) {
                    deletingRecord = nil
                }
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(
                systemName: viewModel.filter == .sent
                    ? "mic.slash" : "ear.trianglebadge.exclamationmark"
            )
            .font(.system(size: 48))
            .foregroundStyle(.quaternary)
            Text("まだ記録がありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(
                viewModel.filter == .sent
                    ? "声を届けると、ここに履歴が残ります"
                    : "声を受け取ると、ここに履歴が残ります"
            )
            .font(.subheadline)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Edit Title Sheet

private struct EditTitleSheet: View {
    let record: VoiceRecord
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var titleText: String

    init(record: VoiceRecord, onSave: @escaping (String) -> Void) {
        self.record = record
        self.onSave = onSave
        _titleText = State(initialValue: record.title ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("タイトルを入力", text: $titleText)
                        .autocorrectionDisabled()
                } header: {
                    Text("タイトル")
                } footer: {
                    Text("空白のままにすると、タイトルは削除されます")
                }
                Section {
                    LabeledContent("日時") {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(record.createdAt, style: .date)
                                .foregroundStyle(.primary)
                            Text(record.createdAt, style: .time)
                                .foregroundStyle(.secondary)
                        }
                    }
                    LabeledContent("種別") {
                        Text(record.kind == .sent ? "送った声" : "受け取った声")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("情報")
                }
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave(titleText)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct VoiceHistoryRow: View {
    let record: VoiceRecord
    let playState: VoiceHistoryPlayState
    let onPlay: () -> Void
    let onStop: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

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
                if let title = record.title, !title.isEmpty {
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(record.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(record.createdAt, style: .date)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(record.createdAt, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Menu {
                Button {
                    onEdit()
                } label: {
                    Label("タイトルを編集", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("削除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
