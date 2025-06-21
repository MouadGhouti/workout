import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) private var dismiss
    @State private var completedExercises: Set<UUID> = []
    @State private var showingCompletionAlert = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        // Workout Header
                        WorkoutHeaderView(workout: workout)
                        
                        // Exercises List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Exercises")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(workout.exercises) { exercise in
                                ExerciseRowView(
                                    exercise: exercise,
                                    isCompleted: completedExercises.contains(exercise.id)
                                ) {
                                    toggleExercise(exercise)
                                }
                            }
                        }
                        
                        // Complete Workout Button
                        if completedExercises.count == workout.exercises.count {
                            Button(action: completeWorkout) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Complete Workout")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                    .padding(.top)
                }
                .navigationTitle("Workout Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .alert("Workout Completed!", isPresented: $showingCompletionAlert) {
                    Button("Great!") {
                        dismiss()
                    }
                } message: {
                    Text("Great job! Your workout has been marked as completed.")
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func toggleExercise(_ exercise: Exercise) {
        if completedExercises.contains(exercise.id) {
            completedExercises.remove(exercise.id)
        } else {
            completedExercises.insert(exercise.id)
        }
    }
    
    private func completeWorkout() {
        workoutManager.completeWorkout(for: Date())
        showingCompletionAlert = true
    }
}

struct WorkoutHeaderView: View {
    let workout: Workout
    
    var body: some View {
        VStack(spacing: 12) {
            Text(workout.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Label(workout.type, systemImage: "dumbbell.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(workout.dayOfWeek, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(workout.exercises.count) exercises")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ExerciseRowView: View {
    let exercise: Exercise
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion Checkbox
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isCompleted ? .green : .gray)
            }
            
            // Exercise Details
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .strikethrough(isCompleted)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                HStack(spacing: 12) {
                    if exercise.sets > 0 {
                        Text("\(exercise.sets) sets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if exercise.reps > 0 {
                        Text("\(exercise.reps) reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let weight = exercise.weight {
                        Text("\(Int(weight))kg")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let duration = exercise.duration {
                        Text("\(duration / 60)min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let notes = exercise.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
//Preview
struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleWorkout = Workout(
            name: "Upper Body Strength",
            type: "Strength",
            dayOfWeek: "Monday",
            exercises: [
                Exercise(name: "Push-ups", sets: 3, reps: 10, weight: nil, duration: nil, notes: "Full body push-ups"),
                Exercise(name: "Pull-ups", sets: 3, reps: 8, weight: nil, duration: nil, notes: "Assisted if needed")
            ]
        )
        
        WorkoutDetailView(workout: sampleWorkout)
            .environmentObject(WorkoutManager())
    }
} 