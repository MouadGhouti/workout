import Foundation

// MARK: - Workout Models
struct Workout: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: String
    let dayOfWeek: String
    let exercises: [Exercise]
    var isCompleted: Bool = false
    var completedDate: Date?
}

struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: Int
    let weight: Double?
    let duration: Int? // in seconds
    let notes: String?
}

struct WorkoutPlan: Codable {
    let name: String
    let workouts: [Workout]
    let schedule: [String: String] // day of week -> workout name
}

// MARK: - Week Day Model
struct WeekDay: Identifiable {
    let id = UUID()
    let name: String
    let shortName: String
    let date: Date
    var isCompleted: Bool = false
}

// MARK: - Workout Types
enum WorkoutType: String, CaseIterable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case custom = "Custom"
} 