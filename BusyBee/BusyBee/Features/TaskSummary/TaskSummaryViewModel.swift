import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class TaskSummaryViewModel: ObservableObject {
    @Published var summary: String = ""
    @Published var isLoading: Bool = false
    @Published var errorText: String?
    
    private let client: GeminiClient
    
    init(client: GeminiClient = GeminiClient()) {
        self.client = client
    }
    
    var isApiKeyMissing: Bool {
        GeminiConfig.apiKey.isEmpty
    }
    
    func summarize(todayItems: [ToDoItem]) async {
        guard !isLoading else { return }
        isLoading = true
        errorText = nil
        defer { isLoading = false }

        guard !todayItems.isEmpty else { return }

        let prompt = summarizePrompt(for: todayItems)
        do {
            let text = try await client.generateText(prompt: prompt)
            summary = text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            summary = ""
            errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
    
    private func summarizePrompt(for items: [ToDoItem]) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        let listLines = items.map { item in
            let time = formatter.string(from: item.dueDate)
            let listName = item.list?.name ?? "General"
            let status = item.isCompleted ? "completed" : "pending"
            return "- [\(status)] \(item.name) — list: \(listName), time: \(time)"
        }.joined(separator: "\n")

        return """
        You are a helpful assistant summarizing a person's to-do list for today. Be concise and actionable.
        Tasks for today (with status, list, and time):
        \(listLines)

        Produce:
        1) A 2–3 sentence overview of the day.
        2) 3–5 prioritized bullet points with suggestions, grouping similar tasks when sensible.
        3) Call out any completed tasks briefly.
        Keep it friendly and motivating. Avoid repeating the raw list verbatim.
        """
    }
}
