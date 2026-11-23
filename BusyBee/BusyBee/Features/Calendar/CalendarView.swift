import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ToDoItem.dueDate) private var allItems: [ToDoItem]
    
    @StateObject private var calendarViewModel = CalendarViewModel()
    @StateObject private var listViewModel = ToDoListViewModel()
    
    var filteredItems: [ToDoItem] {
        calendarViewModel.filterItems(allItems, for: calendarViewModel.selectedDate)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                DatePicker(
                    "Select Date",
                    selection: $calendarViewModel.selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(Color("primaryColor"))
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("TASKS FOR \(calendarViewModel.selectedDate.formatted(date: .abbreviated, time: .omitted).uppercased())")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text("\(filteredItems.count)")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Color("primaryColor"))
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    
                    if filteredItems.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 40))
                                .foregroundStyle(Color("primaryColor").opacity(0.4))
                            
                            Text("No tasks scheduled for this date")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(filteredItems) { item in
                                    HStack(spacing: 12) {
                                        Button {
                                            listViewModel.toggleCompletion(item, context: modelContext)
                                        } label: {
                                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                                .font(.title3)
                                                .foregroundStyle(item.isCompleted ? .green : .gray)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.headline)
                                                .strikethrough(item.isCompleted)
                                                .foregroundStyle(item.isCompleted ? .gray : Color("textColor"))
                                            
                                            if let listName = item.list?.name {
                                                Text(listName)
                                                    .font(.caption)
                                                    .foregroundStyle(Color("primaryColor"))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(item.dueDate.formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(12)
                                    .background(Color("primaryColor").opacity(0.08))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
