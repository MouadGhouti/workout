import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingWorkoutDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Week Progress Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This Week")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        WeekProgressView()
                    }
                    
                    // Today's Workout Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Workout")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if let todayWorkout = workoutManager.getCurrentDayWorkout() {
                            TodayWorkoutCard(workout: todayWorkout)
                                .onTapGesture {
                                    showingWorkoutDetail = true
                                }
                        } else {
                            NoWorkoutCard()
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationTitle("Workout Tracker")
            .sheet(isPresented: $showingWorkoutDetail) {
                if let workout = workoutManager.getCurrentDayWorkout() {
                    WorkoutDetailView(workout: workout)
                }
            }
        }
    }
}

struct WeekProgressView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(workoutManager.currentWeek) { day in
                DayBox(day: day)
            }
        }
        .padding(.horizontal)
    }
}

struct DayBox: View {
    let day: WeekDay
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day.shortName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(day.isCompleted ? .white : .secondary)
            
            Circle()
                .fill(day.isCompleted ? Color.green : Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    day.isCompleted ?
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white) : nil
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct TodayWorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(workout.type)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.dayOfWeek)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(workout.exercises.count) exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Tap to view details")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct NoWorkoutCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No workout scheduled")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Set up your workout plan to get started")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environmentObject(WorkoutManager())
} 