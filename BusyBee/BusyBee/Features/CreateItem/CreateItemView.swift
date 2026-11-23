import SwiftUI
import SwiftData

struct CreateItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDoList.name) private var lists: [ToDoList]
    
    @StateObject private var viewModel = CreateItemViewModel()
    @StateObject private var listViewModel = ToDoListViewModel()
    @State private var showingAddListSheet = false

    var body: some View {
        ItemForm(
            viewModel: viewModel,
            listViewModel: listViewModel,
            lists: lists,
            onDismiss: { dismiss() },
            onAddListTapped: { showingAddListSheet = true }
        )
        .sheet(isPresented: $showingAddListSheet) {
            AddListSheetContent(
                listViewModel: listViewModel,
                isPresented: $showingAddListSheet
            )
        }
    }
}

struct ItemForm: View {
    @ObservedObject var viewModel: CreateItemViewModel
    @ObservedObject var listViewModel: ToDoListViewModel
    let lists: [ToDoList]
    let onDismiss: () -> Void
    let onAddListTapped: () -> Void

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Item Name", text: $viewModel.itemName)

                    DatePicker("Due Date", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Select List")) {
                    if lists.isEmpty {
                        Text("No lists available. Please create one.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("List", selection: $viewModel.selectedList) {
                            Text("Select a list").tag(nil as ToDoList?)
                            ForEach(lists) { list in
                                HStack {
                                    Text(list.icon)
                                    Text(list.name)
                                }
                                .tag(Optional(list))
                            }
                        }
                    }

                    Button(action: onAddListTapped) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create New List")
                        }
                        .foregroundStyle(Color("primaryColor"))
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveItem(using: listViewModel, context: modelContext) {
                            onDismiss()
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .onAppear {
                if viewModel.selectedList == nil {
                    viewModel.selectedList = lists.first
                }
            }
        }
    }
}

struct AddListSheetContent: View {
    @ObservedObject var listViewModel: ToDoListViewModel
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext

    @StateObject private var addListViewModel = AddListViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("List Icon")) {
                    HStack {
                        TextField("Emoji Icon (e.g. 📝)", text: $addListViewModel.icon)
                            .onChange(of: addListViewModel.icon) { _, newValue in
                                addListViewModel.updateIcon(newValue)
                            }
                        if !addListViewModel.icon.isEmpty {
                            Text(addListViewModel.icon)
                                .font(.title2)
                        }
                    }
                }

                Section(header: Text("List Details")) {
                    TextField("List Name", text: $addListViewModel.listName)
                    TextField("Description (Optional)", text: $addListViewModel.listDescription)
                }

                if let errorMessage = addListViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if addListViewModel.saveList(using: listViewModel, context: modelContext) {
                            isPresented = false
                        }
                    }
                    .disabled(!addListViewModel.isValid)
                }
            }
        }
    }
}

#Preview {
    CreateItemView()
}
