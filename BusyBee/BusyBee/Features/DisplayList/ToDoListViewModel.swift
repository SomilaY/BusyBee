import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class ToDoListViewModel: ObservableObject {
    
    func addList(name: String, description: String, icon: String, context: ModelContext) {
        let newList = ToDoList(name: name, listDescription: description, icon: icon)
        context.insert(newList)
        do {
            try context.save()
        } catch {
            print("Failed to save list: \(error)")
        }
    }
    
    func addItem(name: String, dueDate: Date, to list: ToDoList, context: ModelContext) {
        let newItem = ToDoItem(name: name, dueDate: dueDate, isCompleted: false)
        newItem.list = list
        list.items.append(newItem)
        context.insert(newItem)
        do {
            try context.save()
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    
    func toggleCompletion(_ item: ToDoItem, context: ModelContext) {
        item.isCompleted.toggle()
        do {
            try context.save()
        } catch {
            print("Failed to toggle completion: \(error)")
        }
    }
    
    func deleteItem(_ item: ToDoItem, context: ModelContext) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    func deleteList(_ list: ToDoList, context: ModelContext) {
        context.delete(list)
        do {
            try context.save()
        } catch {
            print("Failed to delete list: \(error)")
        }
    }
}
