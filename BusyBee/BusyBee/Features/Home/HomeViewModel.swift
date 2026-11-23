import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var showAllLists: Bool = false
    @Published var showCalendar: Bool = false
    @Published var showCreateItem: Bool = false
    @Published var showAssistant: Bool = false
    
    var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    var formattedDate: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide).year().locale(Locale(identifier: "en_GB")))
    }
    
    var greetingTime: String {
        if currentHour < 12 {
            return "Good Morning"
        } else if currentHour < 18 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
        }
    }
    
    func fetchList(id: UUID, context: ModelContext) -> ToDoList? {
        let predicate = #Predicate<ToDoList> { list in
            list.id == id
        }
        var descriptor = FetchDescriptor<ToDoList>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        return try? context.fetch(descriptor).first
    }
}
