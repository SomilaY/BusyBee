import SwiftUI
import SwiftData

struct TaskSummaryView: View {
    @Query(sort: \ToDoItem.dueDate) private var allItems: [ToDoItem]
    @StateObject private var viewModel = TaskSummaryViewModel()

    private var todayItems: [ToDoItem] {
        allItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: .now) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("containerText"))
                    
                    Text("Today's AI Summary")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("containerText"))
                }
                
                Spacer()
                
                Button(action: { Task { await viewModel.summarize(todayItems: todayItems) } }) {
                    if viewModel.isLoading {
                        ProgressView().tint(Color("containerText"))
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .bold))
                            Text("Refresh")
                                .font(.caption2.bold())
                        }
                        .foregroundStyle(Color("containerText"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading || todayItems.isEmpty || viewModel.isApiKeyMissing)
            }

            Group {
                if viewModel.isApiKeyMissing {
                    Text("Add your GEMINI_API_KEY in Info.plist to enable AI task summaries.")
                        .font(.subheadline)
                        .foregroundStyle(Color("containerText").opacity(0.85))
                } else if todayItems.isEmpty {
                    Text("No tasks scheduled for today. Create a task to generate an AI summary.")
                        .font(.subheadline)
                        .foregroundStyle(Color("containerText").opacity(0.85))
                } else if let errorText = viewModel.errorText {
                    Text(errorText)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                } else if !viewModel.summary.isEmpty {
                    MarkdownText(raw: viewModel.summary)
                        .font(.system(size: 14, weight: .regular))
                        .lineSpacing(4)
                        .foregroundStyle(Color("containerText"))
                } else if viewModel.isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(Color("containerText"))
                        Text("Generating AI summary for today's tasks…")
                            .font(.subheadline)
                            .foregroundStyle(Color("containerText").opacity(0.9))
                    }
                    .padding(.vertical, 4)
                } else {
                    Text("Tap 'Refresh' to generate an intelligent AI overview of your day.")
                        .font(.subheadline)
                        .foregroundStyle(Color("containerText").opacity(0.85))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("primaryColor"),
                            Color("primaryColor").opacity(0.88)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color("primaryColor").opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .task {
            if viewModel.summary.isEmpty && !todayItems.isEmpty && !viewModel.isApiKeyMissing {
                await viewModel.summarize(todayItems: todayItems)
            }
        }
    }
}

#Preview {
    TaskSummaryView()
}
