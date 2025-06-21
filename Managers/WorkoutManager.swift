import Foundation
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var currentWeek: [WeekDay] = []
    @Published var workoutPlan: WorkoutPlan?
    @Published var completedWorkouts: [String: Date] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let completedWorkoutsKey = "completedWorkouts"
    private let workoutPlanKey = "workoutPlan"
    
    init() {
        loadCompletedWorkouts()
        generateCurrentWeek()
        loadWorkoutPlan()
    }
    
    // MARK: - Week Management
    func generateCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        currentWeek = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? today
            let dayName = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let shortName = calendar.veryShortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            let dateString = formatDate(date)
            let isCompleted = completedWorkouts[dateString] != nil
            
            return WeekDay(name: dayName, shortName: shortName, date: date, isCompleted: isCompleted)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Workout Completion
    func completeWorkout(for date: Date) {
        let dateString = formatDate(date)
        completedWorkouts[dateString] = Date()
        saveCompletedWorkouts()
        generateCurrentWeek() // Refresh the week view
    }
    
    func isWorkoutCompleted(for date: Date) -> Bool {
        let dateString = formatDate(date)
        return completedWorkouts[dateString] != nil
    }
    
    // MARK: - Current Day Workouts
    func getCurrentDayWorkouts() -> [Workout] {
        guard let plan = workoutPlan else { return [] }
        let calendar = Calendar.current
        let today = Date()
        let dayName = calendar.weekdaySymbols[calendar.component(.weekday, from: today) - 1]
        return plan.workouts.filter { $0.dayOfWeek == dayName }
    }
    
    // MARK: - Workout Plan Management
    func loadWorkoutPlan() {
        if let data = userDefaults.data(forKey: workoutPlanKey),
           let plan = try? JSONDecoder().decode(WorkoutPlan.self, from: data) {
            workoutPlan = plan
        } else {
            // Load default workout plan
            workoutPlan = createDefaultWorkoutPlan()
        }
    }
    
    func saveWorkoutPlan(_ plan: WorkoutPlan) {
        workoutPlan = plan
        if let data = try? JSONEncoder().encode(plan) {
            userDefaults.set(data, forKey: workoutPlanKey)
        }
    }
    
    private func createDefaultWorkoutPlan() -> WorkoutPlan {
        let defaultWorkouts = [
            Workout(name: "Upper Body Strength", type: "Strength", dayOfWeek: "Monday", exercises: [
                Exercise(name: "Push-ups", sets: 3, reps: 10, weight: nil, duration: nil, notes: "Full body push-ups"),
                Exercise(name: "Pull-ups", sets: 3, reps: 8, weight: nil, duration: nil, notes: "Assisted if needed"),
                Exercise(name: "Dumbbell Rows", sets: 3, reps: 12, weight: 20.0, duration: nil, notes: "Focus on form")
            ]),
            Workout(name: "Cardio Blast", type: "Cardio", dayOfWeek: "Monday", exercises: [
                Exercise(name: "Running", sets: 1, reps: 1, weight: nil, duration: 1200, notes: "20 minutes fast pace"),
                Exercise(name: "Jump Rope", sets: 3, reps: 1, weight: nil, duration: 300, notes: "5 minutes each set")
            ]),
            Workout(name: "Lower Body Strength", type: "Strength", dayOfWeek: "Tuesday", exercises: [
                Exercise(name: "Squats", sets: 3, reps: 15, weight: nil, duration: nil, notes: "Body weight squats"),
                Exercise(name: "Lunges", sets: 3, reps: 10, weight: nil, duration: nil, notes: "Each leg"),
                Exercise(name: "Calf Raises", sets: 3, reps: 20, weight: nil, duration: nil, notes: "Standing calf raises")
            ]),
            Workout(name: "Cardio", type: "Cardio", dayOfWeek: "Wednesday", exercises: [
                Exercise(name: "Running", sets: 1, reps: 1, weight: nil, duration: 1800, notes: "30 minutes moderate pace"),
                Exercise(name: "Jump Rope", sets: 3, reps: 1, weight: nil, duration: 300, notes: "5 minutes each set")
            ]),
            Workout(name: "Core Workout", type: "Strength", dayOfWeek: "Thursday", exercises: [
                Exercise(name: "Plank", sets: 3, reps: 1, weight: nil, duration: 60, notes: "Hold for 60 seconds"),
                Exercise(name: "Crunches", sets: 3, reps: 20, weight: nil, duration: nil, notes: "Slow and controlled"),
                Exercise(name: "Russian Twists", sets: 3, reps: 15, weight: nil, duration: nil, notes: "Each side")
            ]),
            Workout(name: "Full Body", type: "Strength", dayOfWeek: "Friday", exercises: [
                Exercise(name: "Burpees", sets: 3, reps: 10, weight: nil, duration: nil, notes: "Full burpees"),
                Exercise(name: "Mountain Climbers", sets: 3, reps: 1, weight: nil, duration: 300, notes: "5 minutes each set"),
                Exercise(name: "Plank to Downward Dog", sets: 3, reps: 10, weight: nil, duration: nil, notes: "Slow transitions")
            ]),
            Workout(name: "Yoga", type: "Yoga", dayOfWeek: "Saturday", exercises: [
                Exercise(name: "Sun Salutation", sets: 3, reps: 1, weight: nil, duration: 600, notes: "10 minutes flow"),
                Exercise(name: "Warrior Poses", sets: 2, reps: 1, weight: nil, duration: 300, notes: "Hold each pose"),
                Exercise(name: "Meditation", sets: 1, reps: 1, weight: nil, duration: 900, notes: "15 minutes")
            ]),
            Workout(name: "Rest Day", type: "Rest", dayOfWeek: "Sunday", exercises: [
                Exercise(name: "Light Stretching", sets: 1, reps: 1, weight: nil, duration: 600, notes: "10 minutes gentle stretching")
            ])
        ]
        
        let schedule: [String: [String]] = [
            "Monday": ["Upper Body Strength", "Cardio Blast"],
            "Tuesday": ["Lower Body Strength"],
            "Wednesday": ["Cardio"],
            "Thursday": ["Core Workout"],
            "Friday": ["Full Body"],
            "Saturday": ["Yoga"],
            "Sunday": ["Rest Day"]
        ]
        
        return WorkoutPlan(name: "Weekly Fitness Plan", workouts: defaultWorkouts, schedule: schedule)
    }
    
    // MARK: - Persistence
    private func saveCompletedWorkouts() {
        if let data = try? JSONEncoder().encode(completedWorkouts) {
            userDefaults.set(data, forKey: completedWorkoutsKey)
        }
    }
    
    private func loadCompletedWorkouts() {
        if let data = userDefaults.data(forKey: completedWorkoutsKey),
           let workouts = try? JSONDecoder().decode([String: Date].self, from: data) {
            completedWorkouts = workouts
        }
    }
    
    // MARK: - Workouts for Arbitrary Day
    func getWorkouts(for date: Date) -> [Workout] {
        guard let plan = workoutPlan else { return [] }
        let calendar = Calendar.current
        let dayName = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
        return plan.workouts.filter { $0.dayOfWeek == dayName }
    }
} 