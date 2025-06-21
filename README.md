# Workout Tracker iOS App

A comprehensive iOS workout tracking application built with SwiftUI that helps you stay on top of your fitness routine with a beautiful, intuitive interface.

## Features

### 🏠 Home Screen
- **Weekly Progress Tracker**: Seven gray boxes representing each day of the current week
- **Visual Completion**: Completed workout days turn green with a checkmark
- **Today's Workout**: Prominent display of the current day's workout with name, type, and exercise count
- **Quick Access**: Tap the workout card to view detailed exercises

### 📋 Workout Details
- **Exercise List**: View all exercises for the selected workout
- **Progress Tracking**: Check off exercises as you complete them
- **Exercise Information**: Sets, reps, weight, duration, and notes for each exercise
- **Completion**: Mark the entire workout as complete when all exercises are done

### 📅 Workout Plan Management
- **Custom Plans**: Import workout plans using a simple markup format
- **Flexible Scheduling**: Assign workouts to specific days of the week
- **Plan Persistence**: Your workout plans are saved locally
- **Easy Import**: Paste markup text to quickly set up your routine

### 📊 History & Statistics
- **Workout History**: View all completed workouts with dates and times
- **Time-based Filtering**: Filter by week, month, or year
- **Statistics Dashboard**: 
  - Workouts completed
  - Completion rate
  - Current streak
  - Best streak
- **Visual Progress**: Track your fitness journey over time

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.0

### Installation
1. Clone or download the project
2. Open `WorkoutApp.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project (⌘+R)

### Setting Up Your Workout Plan

#### Using the Markup Format
The app supports a simple markup format for importing workout plans:

```
# Workout Name
@ Day of Week
- Exercise Name, sets: 3, reps: 10, weight: 20kg, notes: Optional notes
- Another Exercise, sets: 3, reps: 15, duration: 5min
```

#### Markup Syntax
- `#` - Defines a workout name
- `@` - Specifies the day of the week for the workout
- `-` - Defines an exercise with parameters:
  - `sets: X` - Number of sets
  - `reps: X` - Number of repetitions
  - `weight: Xkg` - Weight in kilograms
  - `duration: Xmin` or `duration: Xsec` - Duration in minutes or seconds
  - Additional text is treated as notes

#### Example Workout Plan
See `sample_workout_plan.txt` for a complete example workout plan that you can import.

## App Structure

```
WorkoutApp/
├── WorkoutApp.swift              # Main app entry point
├── Views/                        # SwiftUI Views
│   ├── ContentView.swift         # Main tab navigation
│   ├── HomeView.swift           # Home screen with week progress
│   ├── WorkoutDetailView.swift  # Exercise details and completion
│   ├── WorkoutPlanView.swift    # Plan management and import
│   └── HistoryView.swift        # Statistics and workout history
├── Managers/                     # Business Logic
│   └── WorkoutManager.swift     # Core app functionality
└── Models/                       # Data Models
    └── WorkoutModels.swift      # Workout, Exercise, and related models
```

## Key Components

### WorkoutManager
- Manages workout data and persistence
- Handles workout completion tracking
- Generates current week view
- Parses and saves workout plans

### Data Models
- `Workout`: Contains workout information and exercises
- `Exercise`: Individual exercise with sets, reps, weight, etc.
- `WorkoutPlan`: Complete workout schedule
- `WeekDay`: Represents a day in the weekly view

### Views
- **HomeView**: Main dashboard with week progress and today's workout
- **WorkoutDetailView**: Detailed exercise view with completion tracking
- **WorkoutPlanView**: Plan management with markup import functionality
- **HistoryView**: Statistics and completed workout history

## Features in Detail

### Weekly Progress Tracking
- Automatically generates the current week view
- Tracks completed workouts by date
- Visual feedback with green checkmarks for completed days
- Persists completion data between app launches

### Workout Completion Flow
1. View today's workout on the home screen
2. Tap to see detailed exercises
3. Check off exercises as you complete them
4. Complete the entire workout when all exercises are done
5. The day's box turns green on the home screen

### Custom Workout Plans
- Import plans using the markup format
- Automatic parsing of workout structure
- Flexible exercise parameters (sets, reps, weight, duration, notes)
- Easy plan switching and management

### Statistics and History
- Comprehensive workout tracking
- Multiple time frame views (week/month/year)
- Streak tracking and completion rates
- Historical workout data

## Design Principles

- **Clean Interface**: Modern, minimalist design with clear visual hierarchy
- **Intuitive Navigation**: Tab-based navigation for easy access to all features
- **Visual Feedback**: Clear indicators for workout completion and progress
- **Responsive Design**: Works seamlessly on all iPhone sizes
- **Accessibility**: Built with accessibility in mind

## Future Enhancements

- Cloud sync for workout data
- Social features and sharing
- Advanced analytics and insights
- Custom exercise library
- Workout templates and presets
- Integration with health apps
- Push notifications and reminders

## Contributing

This is a personal project, but suggestions and improvements are welcome!

## License

This project is open source and available under the MIT License. 