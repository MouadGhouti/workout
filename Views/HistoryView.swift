import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedTimeFrame: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 24) {
                        // GitHub-style month grid
                        MonthGridView()
                        // Time Frame Selector
                        TimeFrameSelector(selectedTimeFrame: $selectedTimeFrame)
                        
                        // Statistics Section
                        StatisticsSection(selectedTimeFrame: selectedTimeFrame)
                        
                        // Completed Workouts Section
                        CompletedWorkoutsSection(selectedTimeFrame: selectedTimeFrame)
                        
                        Spacer()
                    }
                    .frame(minHeight: geometry.size.height)
                    .padding(.top)
                }
                .navigationTitle("Workout History")
            }
        }
    }
}

struct TimeFrameSelector: View {
    @Binding var selectedTimeFrame: HistoryView.TimeFrame
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HistoryView.TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: { selectedTimeFrame = timeFrame }) {
                    Text(timeFrame.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeFrame == timeFrame ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTimeFrame == timeFrame ? Color.green : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct StatisticsSection: View {
    let selectedTimeFrame: HistoryView.TimeFrame
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Workouts Completed",
                    value: "\(completedWorkoutsCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Completion Rate",
                    value: "\(completionRate)%",
                    icon: "percent",
                    color: .blue
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(workoutManager.calculateCurrentStreak())",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Best Streak",
                    value: "\(workoutManager.bestStreak)",
                    icon: "trophy.fill",
                    color: .yellow
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var completedWorkoutsCount: Int {
        let calendar = Calendar.current
        let now = Date()
        
        return workoutManager.completedWorkouts.values.filter { date in
            switch selectedTimeFrame {
            case .week:
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }.count
    }
    
    private var completionRate: Int {
        let totalDays = selectedTimeFrame == .week ? 7 : (selectedTimeFrame == .month ? 30 : 365)
        return Int((Double(completedWorkoutsCount) / Double(totalDays)) * 100)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CompletedWorkoutsSection: View {
    let selectedTimeFrame: HistoryView.TimeFrame
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completed Workouts")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if completedWorkouts.isEmpty {
                EmptyHistoryView()
            } else {
                VStack(spacing: 8) {
                    ForEach(completedWorkouts, id: \.key) { dateString, date in
                        CompletedWorkoutRow(dateString: dateString, date: date)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var completedWorkouts: [(key: String, value: Date)] {
        let calendar = Calendar.current
        let now = Date()
        
        return workoutManager.completedWorkouts.filter { _, date in
            switch selectedTimeFrame {
            case .week:
                return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(date, equalTo: now, toGranularity: .year)
            }
        }.sorted { $0.value > $1.value }
    }
}

struct CompletedWorkoutRow: View {
    let dateString: String
    let date: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(date))
                    .font(.headline)
                
                Text(formatTime(date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No completed workouts yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Complete your first workout to see it here")
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

// Add MonthGridView for GitHub-style contribution grid
struct MonthGridView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let columns = Array(repeating: GridItem(.fixed(16), spacing: 4), count: 7)
    
    var body: some View {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today) ?? (1..<29)
        let components = calendar.dateComponents([.year, .month], from: today)
        let firstOfMonth = calendar.date(from: components) ?? today
        let weekdayOffset = calendar.component(.weekday, from: firstOfMonth) - 1 // 0 = Sunday
        let days = (0..<(range.count)).map { day -> Date in
            calendar.date(byAdding: .day, value: day, to: firstOfMonth)!
        }
        let paddedDays = Array(repeating: Date.distantPast, count: weekdayOffset) + days
        let rows = Int(ceil(Double(paddedDays.count) / 7.0))
        let gridDays = paddedDays + Array(repeating: Date.distantPast, count: rows * 7 - paddedDays.count)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("This Month")
                .font(.headline)
                .padding(.horizontal)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(gridDays.enumerated()), id: \.offset) { idx, date in
                    if calendar.isDate(date, equalTo: Date.distantPast, toGranularity: .day) {
                        Color.clear.frame(width: 16, height: 16)
                    } else {
                        let completed = workoutManager.isWorkoutCompleted(for: date)
                        Rectangle()
                            .fill(completed ? Color.green : Color(.systemGray5))
                            .frame(width: 16, height: 16)
                            .cornerRadius(3)
                            .overlay(
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(WorkoutManager())
} 