import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            WorkoutPlanView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Workout Plan")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
        }
        .accentColor(.green)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .environmentObject(WorkoutManager())
} 