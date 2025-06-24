import SwiftUI

struct HomeView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingWorkoutDetail = false
    @State private var selectedWorkout: Workout? = nil
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var weekOffset: Int = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        // Week Navigation
                        HStack {
                            Button(action: { weekOffset -= 1; updateSelectedDateForWeek() }) {
                                Image(systemName: "chevron.left")
                            }
                            Spacer()
                            Text(weekTitle)
                                .font(.headline)
                            Spacer()
                            Button(action: { weekOffset += 1; updateSelectedDateForWeek() }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .padding(.horizontal)
                        
                        // Week Progress Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("This Week")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            WeekProgressView(selectedDate: $selectedDate, weekOffset: weekOffset)
                        }
                        
                        // Today's Workout Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Today's Workout")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            let selectedDayWorkouts = workoutManager.getWorkouts(for: selectedDate)
                            if !selectedDayWorkouts.isEmpty {
                                ForEach(selectedDayWorkouts) { workout in
                                    TodayWorkoutCard(workout: workout)
                                        .onTapGesture {
                                            selectedWorkout = workout
                                            showingWorkoutDetail = true
                                        }
                                }
                            } else {
                                NoWorkoutCard()
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                    .padding(.top)
                }
                .navigationTitle("Workout Tracker")
                .sheet(isPresented: $showingWorkoutDetail) {
                    if let workout = selectedWorkout {
                        WorkoutDetailView(workout: workout)
                    }
                }
            }
        }
    }
    
    private func updateSelectedDateForWeek() {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfDay(for: today)) ?? today
        if !calendar.isDate(selectedDate, equalTo: weekStart, toGranularity: .weekOfYear) {
            selectedDate = weekStart
        }
    }
    
    private var weekTitle: String {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfDay(for: today)) ?? today
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
}

struct WeekProgressView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Binding var selectedDate: Date
    var weekOffset: Int
    
    var body: some View {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: calendar.startOfDay(for: today)) ?? today
        let days = (0..<7).map { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart) ?? weekStart
        }
        HStack(spacing: 8) {
            ForEach(days, id: \ .self) { date in
                let day = workoutManager.getWeekDay(for: date)
                DayBox(day: day, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                    .onTapGesture {
                        selectedDate = date
                    }
            }
        }
        .padding(.horizontal)
    }
}

struct DayBox: View {
    let day: WeekDay
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(day.isCompleted ? Color.green : Color.gray.opacity(0.3))
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                    .frame(width: 32, height: 32)
                Text(day.shortName)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(day.isCompleted ? Color.white.opacity(0.7) : .secondary)
                if day.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .background(Color.green.opacity(0.7).clipShape(Circle()))
                }
            }
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