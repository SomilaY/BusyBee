import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class CreateItemViewModel: ObservableObject {
    @Published var itemName: String = ""
    @Published var date: Date = Date()
    @Published var selectedList: ToDoList?
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedList != nil
    }
    
    func saveItem(using listViewModel: ToDoListViewModel, context: ModelContext) -> Bool {
        guard let list = selectedList, !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please select a list and enter an item name."
            return false
        }
        listViewModel.addItem(
            name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: date,
            to: list,
            context: context
        )
        itemName = ""
        return true
    }
}

@MainActor
final class AddListViewModel: ObservableObject {
    @Published var icon: String = ""
    @Published var listName: String = ""
    @Published var listDescription: String = ""
    @Published var errorMessage: String?
    
    var isValid: Bool {
        !listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func updateIcon(_ newValue: String) {
        if let last = newValue.last {
            icon = String(last)
        }
    }
    
    func saveList(using listViewModel: ToDoListViewModel, context: ModelContext) -> Bool {
        let trimmedName = listName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIcon = icon.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = listDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty, !trimmedIcon.isEmpty else {
            errorMessage = "Please provide both an icon and a list name."
            return false
        }
        
        listViewModel.addList(
            name: trimmedName,
            description: trimmedDescription,
            icon: trimmedIcon,
            context: context
        )
        return true
    }
}
