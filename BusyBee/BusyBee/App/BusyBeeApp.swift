import SwiftUI
import SwiftData

@main
struct BusyBeeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
        }
        .modelContainer(for: [ToDoList.self, ToDoItem.self])
    }
}
