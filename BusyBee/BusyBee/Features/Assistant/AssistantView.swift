
import SwiftUI
import SwiftData

struct AssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AssistantViewModel()
    @Query(sort: \ToDoItem.dueDate) private var allItems: [ToDoItem]
    var weather: WeatherResponse? = nil

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { msg in
                        HStack {
                            if msg.role == .assistant {
                                MarkdownText(raw: msg.text)
                                    .font(.subheadline)
                                    .padding(12)
                                    .background(
                                        .ultraThinMaterial,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                                Spacer(minLength: 40)
                            } else {
                                Spacer(minLength: 40)
                                Text(msg.text)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .padding(12)
                                    .background(
                                        Color.accentColor,
                                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    )
                            }
                        }
                    }

                    if let errorText = viewModel.errorText {
                        Text(errorText)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
            }

            HStack(spacing: 10) {
                TextField("Ask anything...", text: $viewModel.input, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)

                Button(action: { viewModel.send(items: allItems, weather: weather) }) {
                    if viewModel.isSending {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                viewModel.input.isEmpty
                                ? .secondary
                                : Color.accentColor
                            )
                    }
                }
                .disabled(
                    viewModel.input.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ).isEmpty || viewModel.isSending
                )
            }
            .padding(12)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle("Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AssistantView()
    }
}
