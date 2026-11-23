import Foundation
import Combine
import SwiftData
import SwiftUI

@MainActor
final class DisplayListViewModel: ObservableObject {
    @Published var showSearch: Bool = false
    @Published var searchText: String = ""
    
    func filterLists(_ lists: [ToDoList]) -> [ToDoList] {
        guard !searchText.isEmpty else { return lists }
        return lists.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
