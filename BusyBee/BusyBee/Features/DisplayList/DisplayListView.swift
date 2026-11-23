import SwiftUI
import SwiftData

struct DisplayListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDoList.createdAt) private var lists: [ToDoList]

    @StateObject private var displayListViewModel = DisplayListViewModel()
    @StateObject private var listViewModel = ToDoListViewModel()

    var filteredLists: [ToDoList] {
        displayListViewModel.filterLists(lists)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if displayListViewModel.showSearch {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray)
                        
                        TextField("Search lists...", text: $displayListViewModel.searchText)
                            .textFieldStyle(.plain)

                        if !displayListViewModel.searchText.isEmpty {
                            Button {
                                displayListViewModel.searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                if filteredLists.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(Color("primaryColor").opacity(0.5))

                        Text(displayListViewModel.searchText.isEmpty ? "No Lists Created" : "No Matching Lists")
                            .font(.headline)
                            .foregroundStyle(Color("textColor"))

                        Text(displayListViewModel.searchText.isEmpty ? "Create your first list to get started" : "Try a different search term")
                            .font(.subheadline)
                            .foregroundStyle(Color("textColor").opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredLists) { list in
                            Section {
                                ListCardHeader(list: list, listViewModel: listViewModel)
                                
                                ForEach(list.items) { item in
                                    TaskRowView(item: item, listViewModel: listViewModel)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("All Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation {
                            displayListViewModel.showSearch.toggle()
                            if !displayListViewModel.showSearch {
                                displayListViewModel.searchText = ""
                            }
                        }
                    } label: {
                        Image(systemName: displayListViewModel.showSearch ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    }
                }
            }
        }
    }
}

struct ListCardHeader: View {
    let list: ToDoList
    @ObservedObject var listViewModel: ToDoListViewModel
    @Environment(\.modelContext) private var modelContext

    var completedCount: Int {
        list.items.filter(\.isCompleted).count
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(list.icon)
                .font(.title)

            VStack(alignment: .leading, spacing: 2) {
                Text(list.name)
                    .font(.headline)

                if !list.listDescription.isEmpty {
                    Text(list.listDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("\(completedCount) of \(list.items.count) completed")
                    .font(.caption2)
                    .foregroundStyle(Color("primaryColor"))
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                listViewModel.deleteList(list, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct TaskRowView: View {
    let item: ToDoItem
    @ObservedObject var listViewModel: ToDoListViewModel
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Button {
                listViewModel.toggleCompletion(item, context: modelContext)
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                Text(item.dueDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                listViewModel.deleteItem(item, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    DisplayListView()
}
