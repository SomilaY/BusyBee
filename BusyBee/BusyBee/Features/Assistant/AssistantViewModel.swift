import Foundation
import Combine
import SwiftUI

struct Message: Identifiable, Hashable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
}

@MainActor
final class AssistantViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var messages: [Message] = []
    @Published var isSending: Bool = false
    @Published var errorText: String?

    private let client: GeminiClient

    init(client: GeminiClient = GeminiClient()) {
        self.client = client
    }

    func send(items: [ToDoItem], weather: WeatherResponse?) {
        let question = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty else { return }
        input = ""

        messages.append(Message(role: .user, text: question))
        isSending = true
        errorText = nil

        let prompt = buildPrompt(question: question, items: items, weather: weather)

        Task {
            do {
                let reply = try await client.generateText(prompt: prompt)
                messages.append(Message(role: .assistant, text: reply))
            } catch {
                errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
            isSending = false
        }
    }


    private func buildPrompt(question: String, items: [ToDoItem], weather: WeatherResponse?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let calendar = Calendar.current

        let todayItems = items.filter { calendar.isDate($0.dueDate, inSameDayAs: .now) }
        let otherPending = items.filter {
            !calendar.isDate($0.dueDate, inSameDayAs: .now) && !$0.isCompleted
        }

        func line(for item: ToDoItem) -> String {
            let status = item.isCompleted ? "completed" : "pending"
            let listName = item.list?.name ?? "General"
            return "- [\(status)] \(item.name) — list: \(listName), due: \(formatter.string(from: item.dueDate))"
        }

        let todayText = todayItems.isEmpty
            ? "No tasks today."
            : todayItems.map(line(for:)).joined(separator: "\n")

        let otherText = otherPending.isEmpty
            ? "None."
            : otherPending.prefix(15).map(line(for:)).joined(separator: "\n")

        return """
        You are a friendly personal assistant inside a to-do list app.
        Use the context below when it is relevant to the user's question.
        If the question has nothing to do with their tasks or weather, just answer normally.
        Never invent tasks that are not listed.

        Current date and time: \(formatter.string(from: .now))

        Weather right now:
        \(weatherText(weather))

        Tasks due today:
        \(todayText)

        Other pending tasks:
        \(otherText)

        User's question:
        \(question)
        """
    }

    private func weatherText(_ weather: WeatherResponse?) -> String {
        guard let weather else { return "Weather data is not available." }

        let temp = String(format: "%.1f", weather.main.temp)
        let condition = weather.weather.first?.description ?? "unknown conditions"

        func time(_ unix: Int) -> String {
            Date(timeIntervalSince1970: TimeInterval(unix))
                .formatted(date: .omitted, time: .shortened)
        }

        return "\(temp)°C, \(condition). Sunrise \(time(weather.sys.sunrise)), sunset \(time(weather.sys.sunset))."
    }
}
