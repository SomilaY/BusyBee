import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class OverviewViewModel: ObservableObject {
    @Published var searchText: String = ""
    
    func todayItems(from allItems: [ToDoItem]) -> [ToDoItem] {
        allItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: .now) }
    }
    
    func filteredLists(from lists: [ToDoList]) -> [ToDoList] {
        guard !searchText.isEmpty else { return lists }
        return lists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
