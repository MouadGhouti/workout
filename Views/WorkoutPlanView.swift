import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var showingMarkupInput = false
    @State private var markupText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Plan Section
                        if let plan = workoutManager.workoutPlan {
                            CurrentPlanSection(plan: plan)
                        }
                        
                        // Import Section
                        ImportSection(
                            showingMarkupInput: $showingMarkupInput,
                            markupText: $markupText,
                            onImport: importWorkoutPlan
                        )
                        
                        // Instructions Section
                        InstructionsSection()
                        
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                    .padding(.top)
                }
                .navigationTitle("Workout Plan")
                .sheet(isPresented: $showingMarkupInput) {
                    MarkupInputView(
                        markupText: $markupText,
                        onImport: importWorkoutPlan
                    )
                }
                .alert("Import Result", isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func importWorkoutPlan() {
        do {
            let plan = try parseMarkup(markupText)
            workoutManager.saveWorkoutPlan(plan)
            alertMessage = "Workout plan imported successfully!"
            showingAlert = true
            markupText = ""
        } catch {
            alertMessage = "Error importing workout plan: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func parseMarkup(_ markup: String) throws -> WorkoutPlan {
        let lines = markup.components(separatedBy: .newlines)
        var workouts: [Workout] = []
        var schedule: [String: [String]] = [:]
        var currentWorkout: String?
        var currentDay: String?
        var currentExercises: [Exercise] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            // Check for workout header (starts with #)
            if trimmedLine.hasPrefix("#") {
                // Save previous workout if exists
                if let workoutName = currentWorkout,
                   let day = currentDay {
                    let workout = Workout(
                        name: workoutName,
                        type: "Custom",
                        dayOfWeek: day,
                        exercises: currentExercises
                    )
                    workouts.append(workout)
                    if schedule[day] != nil {
                        schedule[day]?.append(workoutName)
                    } else {
                        schedule[day] = [workoutName]
                    }
                }
                
                // Parse new workout
                let workoutName = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
                currentWorkout = workoutName
                currentExercises = []
                
                // Extract day from workout name if it contains day info
                let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                for day in dayNames {
                    if workoutName.contains(day) {
                        currentDay = day
                        break
                    }
                }
            }
            // Check for exercise (starts with -)
            else if trimmedLine.hasPrefix("-") {
                let exerciseText = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
                let exercise = parseExercise(exerciseText)
                currentExercises.append(exercise)
            }
            // Check for day specification (starts with @)
            else if trimmedLine.hasPrefix("@") {
                let dayText = String(trimmedLine.dropFirst()).trimmingCharacters(in: .whitespaces)
                currentDay = dayText
            }
        }
        
        // Save last workout
        if let workoutName = currentWorkout,
           let day = currentDay {
            let workout = Workout(
                name: workoutName,
                type: "Custom",
                dayOfWeek: day,
                exercises: currentExercises
            )
            workouts.append(workout)
            if schedule[day] != nil {
                schedule[day]?.append(workoutName)
            } else {
                schedule[day] = [workoutName]
            }
        }
        
        guard !workouts.isEmpty else {
            throw WorkoutPlanError.noWorkoutsFound
        }
        
        return WorkoutPlan(name: "Custom Plan", workouts: workouts, schedule: schedule)
    }
    
    private func parseExercise(_ exerciseText: String) -> Exercise {
        // Simple parsing - can be enhanced
        let components = exerciseText.components(separatedBy: ",")
        let name = components.first?.trimmingCharacters(in: .whitespaces) ?? exerciseText
        
        var sets = 3
        var reps = 10
        var weight: Double? = nil
        var duration: Int? = nil
        var notes: String? = nil
        
        for component in components.dropFirst() {
            let trimmed = component.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("sets") {
                sets = Int(trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 3
            } else if trimmed.contains("reps") {
                reps = Int(trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 10
            } else if trimmed.contains("kg") {
                weight = Double(trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
            } else if trimmed.contains("min") {
                let minutes = Int(trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
                duration = minutes * 60
            } else {
                notes = trimmed
            }
        }
        
        return Exercise(name: name, sets: sets, reps: reps, weight: weight, duration: duration, notes: notes)
    }
}

struct CurrentPlanSection: View {
    let plan: WorkoutPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Plan")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(plan.workouts) { workout in
                    WorkoutPlanRow(workout: workout)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct WorkoutPlanRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                
                Text(workout.dayOfWeek)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(workout.exercises.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ImportSection: View {
    @Binding var showingMarkupInput: Bool
    @Binding var markupText: String
    let onImport: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import Workout Plan")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Button(action: { showingMarkupInput = true }) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Paste Markup File")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

struct InstructionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Markup Format")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Use the following format:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("# Workout Name")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    Text("@ Day of Week")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    Text("- Exercise Name, sets: 3, reps: 10, weight: 20kg")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    Text("- Another Exercise, sets: 3, reps: 15")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding(.horizontal)
        }
    }
}

struct MarkupInputView: View {
    @Binding var markupText: String
    let onImport: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $markupText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding()
                
                Button("Import Plan") {
                    onImport()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(markupText.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Paste Markup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

enum WorkoutPlanError: Error, LocalizedError {
    case noWorkoutsFound
    
    var errorDescription: String? {
        switch self {
        case .noWorkoutsFound:
            return "No workouts found in the markup file"
        }
    }
}

#Preview {
    WorkoutPlanView()
        .environmentObject(WorkoutManager())
} 