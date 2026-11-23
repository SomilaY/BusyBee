import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    
    func filterItems(_ items: [ToDoItem], for date: Date) -> [ToDoItem] {
        items.filter { item in
            Calendar.current.isDate(item.dueDate, inSameDayAs: date)
        }
    }
}
