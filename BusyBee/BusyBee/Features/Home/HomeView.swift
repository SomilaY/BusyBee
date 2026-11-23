// xcode: set sdk=iOS

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @StateObject private var weatherViewModel = WeatherViewModel()

    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color("backgroundColor", bundle: nil)
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        Greeting(weather: weatherViewModel.weather)
                            .padding(.top, 16)
                        
                        WeatherView(weatherViewModel: weatherViewModel)
                        
                        OverviewView()
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OverviewView: View {
    @Query(sort: \ToDoList.createdAt) private var lists: [ToDoList]
    @StateObject private var overviewViewModel = OverviewViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var filteredLists: [ToDoList] {
        overviewViewModel.filteredLists(from: lists)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Text("TODAYS TASKS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(1.2)
            }
          
            TaskSummaryView()
                .padding(.horizontal, -16)
            
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("YOUR LISTS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .tracking(1.2)
                    
                    Spacer()
                    
                    Text("\(lists.count) \(lists.count == 1 ? "List" : "Lists")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
            
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.gray)
                    
                    TextField("Search lists...", text: $overviewViewModel.searchText)
                        .font(.subheadline)
                        .textFieldStyle(.plain)

                    if !overviewViewModel.searchText.isEmpty {
                        Button {
                            overviewViewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.gray.opacity(0.09))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                        )
                )
                
                // List Cards
                if filteredLists.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 32))
                            .foregroundStyle(Color("primaryColor").opacity(0.4))
                        
                        Text(overviewViewModel.searchText.isEmpty ? "No lists available" : "No matching lists")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("textColor"))
                        
                        Text(overviewViewModel.searchText.isEmpty ? "Tap '+' above to create your first list." : "Try searching for another keyword.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                } else {
                    VStack(spacing: 14) {
                        ForEach(filteredLists) { list in
                            ListCard(list: list)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct Greeting: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HomeViewModel()
    
    var weather: WeatherResponse? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("\(viewModel.greetingTime)")
                    .font(.title2.bold())
                    .foregroundStyle(Color("textColor"))
                
                Text("\(viewModel.formattedDate)")
                    .font(.subheadline)
                    .foregroundStyle(Color("textColor").opacity(0.6))
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                Menu {
                    Button("All Lists", systemImage: "rectangle.stack") {
                        viewModel.showAllLists = true
                    }
                    Button("Calendar", systemImage: "calendar") {
                        viewModel.showCalendar = true
                    }
                    Button("AI Assistant", systemImage: "sparkles") {
                        viewModel.showAssistant = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("textColor"))
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                
                Button {
                    viewModel.showCreateItem = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color("primaryColor"))
                                .shadow(color: Color("primaryColor").opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .fullScreenCover(isPresented: $viewModel.showAllLists) {
            DisplayListView()
        }
        .fullScreenCover(isPresented: $viewModel.showCalendar) {
            CalendarView()
        }
        .fullScreenCover(isPresented: $viewModel.showCreateItem) {
            CreateItemView()
        }
        .fullScreenCover(isPresented: $viewModel.showAssistant) {
            NavigationStack { AssistantView(weather: weather) }
        }
    }
}

struct ListCard: View {
    let list: ToDoList
    
    var completedCount: Int {
        list.items.filter(\.isCompleted).count
    }
    
    var progress: Double {
        list.items.isEmpty ? 0 : Double(completedCount) / Double(list.items.count)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Text(list.icon)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("containerText"))
                
                if !list.listDescription.isEmpty {
                    Text(list.listDescription)
                        .font(.caption)
                        .foregroundStyle(Color("containerText").opacity(0.8))
                        .lineLimit(2)
                }
                
                HStack(spacing: 6) {
                    Text("\(completedCount)/\(list.items.count) completed")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color("containerText").opacity(0.9))
                }
            }
            
            Spacer(minLength: 8)
            
            ZStack {
                Gauge(value: progress) {
                    Text("")
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(Color("containerText"))
                .frame(width: 40, height: 40)
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color("containerText"))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("primaryColor"))
                .shadow(color: Color("primaryColor").opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    HomeView()
}
