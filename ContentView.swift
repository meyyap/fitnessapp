//
//  ContentView.swift
//  pushpullrun
//
//  Created by Meyyappan Thenappan on 3/5/25.
//

import SwiftUI

// MARK: - Models

// User profile model
struct UserProfile: Identifiable, Codable {
    var id = UUID()
    var username: String
    var email: String
    var joinDate: Date
    var profileImage: String? // For storing image name or URL
    var height: Double? // in cm
    var weight: Double? // in kg
    var fitnessGoals: [String] = []
}

// Exercise model
struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: ExerciseCategory
    var muscleGroups: [MuscleGroup]
    var description: String
    var instructions: [String] = []
    var difficultyLevel: DifficultyLevel
    var equipment: [Equipment] = []
    var imageNames: [String] = [] // For demonstration images
}

// Workout model
struct Workout: Identifiable, Codable {
    var id = UUID()
    var name: String
    var date: Date
    var duration: TimeInterval // in seconds
    var exercises: [WorkoutExercise]
    var notes: String?
    var workoutType: WorkoutType
}

// Exercise within a workout
struct WorkoutExercise: Identifiable, Codable {
    var id = UUID()
    var exercise: Exercise
    var sets: [ExerciseSet]
    var notes: String?
}

// Set details for strength exercises
struct ExerciseSet: Identifiable, Codable {
    var id = UUID()
    var reps: Int?
    var weight: Double? // in kg
    var duration: TimeInterval? // for timed exercises
    var distance: Double? // for distance-based exercises (in meters)
    var completed: Bool = false
}

// MARK: - Enums

enum ExerciseCategory: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case balance = "Balance"
    case functional = "Functional"
}

enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    case abs = "Abs"
    case quads = "Quadriceps"
    case hamstrings = "Hamstrings"
    case glutes = "Glutes"
    case calves = "Calves"
    case fullBody = "Full Body"
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum Equipment: String, CaseIterable, Codable {
    case none = "None"
    case dumbbell = "Dumbbell"
    case barbell = "Barbell"
    case kettlebell = "Kettlebell"
    case resistanceBand = "Resistance Band"
    case machine = "Machine"
    case bodyWeight = "Body Weight"
    case treadmill = "Treadmill"
    case bicycle = "Bicycle"
    case jumpRope = "Jump Rope"
    case other = "Other"
}

enum WorkoutType: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case hiit = "HIIT"
    case flexibility = "Flexibility"
    case custom = "Custom"
}

// MARK: - Sample Data

// Sample exercise data
let sampleExercises = [
    Exercise(
        name: "Barbell Bench Press",
        category: .strength,
        muscleGroups: [.chest, .shoulders, .triceps],
        description: "A compound exercise that targets the chest, shoulders, and triceps.",
        instructions: [
            "Lie on a flat bench with your feet flat on the floor.",
            "Grip the barbell slightly wider than shoulder-width apart.",
            "Lower the barbell to your chest, keeping your elbows at a 45-degree angle.",
            "Press the barbell back up to the starting position."
        ],
        difficultyLevel: .intermediate,
        equipment: [.barbell],
        imageNames: ["bench_press_1", "bench_press_2"]
    ),
    Exercise(
        name: "Pull-up",
        category: .strength,
        muscleGroups: [.back, .biceps, .forearms],
        description: "A bodyweight exercise that targets the back and arms.",
        instructions: [
            "Hang from a pull-up bar with hands slightly wider than shoulder-width apart.",
            "Pull your body up until your chin is over the bar.",
            "Lower yourself back down with control."
        ],
        difficultyLevel: .intermediate,
        equipment: [.bodyWeight],
        imageNames: ["pullup_1"]
    ),
    Exercise(
        name: "Running",
        category: .cardio,
        muscleGroups: [.quads, .hamstrings, .calves, .glutes],
        description: "A cardiovascular exercise that improves endurance and burns calories.",
        instructions: [
            "Start with a warm-up walk or light jog.",
            "Maintain good posture with a slight forward lean.",
            "Land midfoot and roll through to push off with your toes.",
            "Cool down with a walk at the end."
        ],
        difficultyLevel: .beginner,
        equipment: [.none, .treadmill],
        imageNames: ["running_1"]
    )
]

// MARK: - Data Persistence
class DataStore {
    static let shared = DataStore()
    
    private let userDefaultsKey = "pushpullrun_user"
    private let exercisesKey = "pushpullrun_exercises"
    private let workoutsKey = "pushpullrun_workouts"
    
    // MARK: - User Profile
    
    func saveUser(_ user: UserProfile) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func loadUser() -> UserProfile? {
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            return user
        }
        return nil
    }
    
    // MARK: - Exercises
    
    func saveExercises(_ exercises: [Exercise]) {
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: exercisesKey)
        }
    }
    
    func loadExercises() -> [Exercise] {
        if let exercisesData = UserDefaults.standard.data(forKey: exercisesKey),
           let exercises = try? JSONDecoder().decode([Exercise].self, from: exercisesData) {
            return exercises
        }
        return []
    }
    
    // MARK: - Workouts
    
    func saveWorkouts(_ workouts: [Workout]) {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: workoutsKey)
        }
    }
    
    func loadWorkouts() -> [Workout] {
        if let workoutsData = UserDefaults.standard.data(forKey: workoutsKey),
           let workouts = try? JSONDecoder().decode([Workout].self, from: workoutsData) {
            return workouts
        }
        return []
    }
}

// MARK: - Authentication State
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Check if user is already signed in
        if let firebaseUser = FirebaseManager.shared.getCurrentUser() {
            self.isLoading = true
            
            FirebaseManager.shared.ensureUserProfileExists { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    switch result {
                    case .success(let userProfile):
                        self?.currentUser = userProfile
                        self?.isAuthenticated = true
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Failed to ensure user profile exists: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let userProfile):
                    self?.currentUser = userProfile
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to sign in: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func register(username: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.createUser(email: email, password: password, username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let userProfile):
                    self?.currentUser = userProfile
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to create user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func logout() {
        let result = FirebaseManager.shared.signOut()
        
        switch result {
        case .success:
            isAuthenticated = false
            currentUser = nil
        case .failure(let error):
            errorMessage = error.localizedDescription
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.resetPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to reset password: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    func updateProfile(height: Double?, weight: Double?, goals: [String]) {
        guard let currentUser = currentUser, let firebaseUser = FirebaseManager.shared.getCurrentUser() else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var updatedUser = currentUser
        updatedUser.height = height
        updatedUser.weight = weight
        updatedUser.fitnessGoals = goals
        
        FirebaseManager.shared.updateUserProfile(updatedUser, userId: firebaseUser.uid) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.currentUser = updatedUser
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to update profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // Main app UI with tabs
                TabView(selection: $selectedTab) {
                    // Home Tab
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    // Exercises Tab
                    ExerciseLibraryView()
                        .tabItem {
                            Label("Exercises", systemImage: "dumbbell.fill")
                        }
                        .tag(1)
                    
                    // Workouts Tab
                    WorkoutsView()
                        .tabItem {
                            Label("Workouts", systemImage: "figure.run")
                        }
                        .tag(2)
                    
                    // Profile Tab
                    ProfileView(authViewModel: authViewModel)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(3)
                }
            } else {
                // Authentication UI
                AuthView(authViewModel: authViewModel)
            }
        }
    }
}

// MARK: - Authentication Views
struct AuthView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isShowingLogin = true
    
    var body: some View {
        NavigationView {
            VStack {
                // App logo
                VStack(spacing: 20) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                    
                    Text("PushPullRun")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your Personal Workout Tracker")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Auth form
                if isShowingLogin {
                    LoginView(authViewModel: authViewModel)
                        .transition(.opacity)
                } else {
                    RegisterView(authViewModel: authViewModel)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Toggle between login and register
                Button(action: {
                    withAnimation {
                        isShowingLogin.toggle()
                    }
                }) {
                    Text(isShowingLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
}

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingResetPassword = false
    @State private var resetEmail = ""
    @State private var showingResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .customTextField()
                
                SecureField("Password", text: $password)
                    .customPasswordField()
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
            }
            
            Button(action: {
                if email.isEmpty || password.isEmpty {
                    authViewModel.errorMessage = "Please fill in all fields"
                } else {
                    authViewModel.login(email: email, password: password)
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(authViewModel.isLoading)
            .padding(.top, 10)
            
            Button(action: {
                showingResetPassword = true
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .alert("Reset Password", isPresented: $showingResetPassword) {
            TextField("Email", text: $resetEmail)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            Button("Cancel", role: .cancel) {
                resetEmail = ""
            }
            
            Button("Reset") {
                if !resetEmail.isEmpty {
                    authViewModel.resetPassword(email: resetEmail) { success in
                        if success {
                            showingResetConfirmation = true
                        }
                    }
                }
            }
        } message: {
            Text("Enter your email address and we'll send you a link to reset your password.")
        }
        .alert("Password Reset Email Sent", isPresented: $showingResetConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Check your email for instructions on how to reset your password.")
        }
    }
}

struct RegisterView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .customTextField()
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .customTextField()
                
                SecureField("Password", text: $password)
                    .customPasswordField()
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .customPasswordField()
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 5)
            }
            
            Button(action: {
                if username.isEmpty || email.isEmpty || password.isEmpty {
                    authViewModel.errorMessage = "Please fill in all fields"
                } else if password != confirmPassword {
                    authViewModel.errorMessage = "Passwords do not match"
                } else {
                    authViewModel.register(username: username, email: email, password: password)
                }
            }) {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(authViewModel.isLoading)
            .padding(.top, 10)
            
            Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
        .padding(.horizontal)
    }
}

// MARK: - Home View
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Quick start section
                VStack(alignment: .leading) {
                    Text("Quick Start")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Action to start a new workout
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().fill(Color.blue))
                            
                            Text("Start New Workout")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Recent workouts section
                VStack(alignment: .leading) {
                    Text("Recent Workouts")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if true { // Replace with condition to check if there are recent workouts
                        Text("No recent workouts")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("PushPullRun")
        }
    }
}

// MARK: - Exercise Library View
struct ExerciseLibraryView: View {
    @State private var searchText = ""
    @State private var exercises: [Exercise] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        } else {
            return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search exercises", text: $searchText)
                        .autocapitalization(.none)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Loading exercises...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 70))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Exercises")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            loadExercises()
                        }) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if exercises.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dumbbell")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        
                        Text("No Exercises Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add exercises to your library or check back later")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Exercise list
                    List(filteredExercises) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            HStack {
                                Image(systemName: exercise.category == .cardio ? "figure.run" : "dumbbell")
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .fontWeight(.semibold)
                                    
                                    Text(exercise.category.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        loadExercises()
                    }
                }
            }
            .navigationTitle("Exercise Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action to add a new exercise
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                if exercises.isEmpty {
                    loadExercises()
                }
            }
        }
    }
    
    func loadExercises() {
        isLoading = true
        errorMessage = nil
        
        // First try to load from Firebase
        FirebaseManager.shared.fetchExercises { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let fetchedExercises):
                    if !fetchedExercises.isEmpty {
                        exercises = fetchedExercises
                    } else {
                        // If no exercises in Firebase, use sample data
                        exercises = sampleExercises
                        
                        // Save sample exercises to Firebase for future use
                        for exercise in sampleExercises {
                            FirebaseManager.shared.saveExercise(exercise) { _ in }
                        }
                    }
                case .failure(let error):
                    // If Firebase fails, fall back to sample data
                    exercises = sampleExercises
                    errorMessage = error.localizedDescription
                    print("Failed to fetch exercises: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Exercise Detail View
struct ExerciseDetailView: View {
    let exercise: Exercise
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Exercise image placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: exercise.category == .cardio ? "figure.run" : "dumbbell")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
                
                // Exercise details
                VStack(alignment: .leading, spacing: 15) {
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(exercise.description)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Muscle groups
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Muscle Groups")
                            .font(.headline)
                        
                        HStack {
                            ForEach(exercise.muscleGroups, id: \.self) { muscle in
                                Text(muscle.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Instructions")
                            .font(.headline)
                        
                        ForEach(exercise.instructions.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .fontWeight(.bold)
                                    .frame(width: 25, alignment: .leading)
                                
                                Text(exercise.instructions[index])
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Workouts View
struct WorkoutsView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    @State private var workouts: [Workout] = []
    @State private var showingCreateWorkout = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading workouts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 70))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Workouts")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            loadWorkouts()
                        }) {
                            Text("Try Again")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if workouts.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        
                        Text("No Workouts Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start tracking your workouts to see them here")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showingCreateWorkout = true
                        }) {
                            Text("Create Workout")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 200)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Workout list
                    List {
                        ForEach(workouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutRow(workout: workout)
                            }
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        loadWorkouts()
                    }
                }
            }
            .navigationTitle("My Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateWorkout = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showingCreateWorkout) {
                CreateWorkoutView(isPresented: $showingCreateWorkout, onSave: { newWorkout in
                    saveWorkout(newWorkout)
                })
            }
            .onAppear {
                loadWorkouts()
            }
        }
    }
    
    func loadWorkouts() {
        guard let firebaseUser = FirebaseManager.shared.getCurrentUser() else {
            errorMessage = "You must be logged in to view workouts"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.fetchWorkouts(userId: firebaseUser.uid) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let fetchedWorkouts):
                    workouts = fetchedWorkouts
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("Failed to fetch workouts: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveWorkout(_ workout: Workout) {
        guard let firebaseUser = FirebaseManager.shared.getCurrentUser() else {
            errorMessage = "You must be logged in to save workouts"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        FirebaseManager.shared.saveWorkout(workout, userId: firebaseUser.uid) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    // Add the new workout to the list
                    workouts.append(workout)
                    // Sort workouts by date (newest first)
                    workouts.sort { $0.date > $1.date }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    print("Failed to save workout: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        guard let firebaseUser = FirebaseManager.shared.getCurrentUser() else {
            errorMessage = "You must be logged in to delete workouts"
            return
        }
        
        for index in offsets {
            let workout = workouts[index]
            
            FirebaseManager.shared.deleteWorkout(workoutId: workout.id, userId: firebaseUser.uid) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // The workout will be removed from the list by the ForEach.onDelete
                        print("Workout deleted successfully")
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        print("Failed to delete workout: \(error.localizedDescription)")
                        // Reload workouts to ensure UI is in sync with backend
                        loadWorkouts()
                    }
                }
            }
        }
        
        // Remove from local array
        workouts.remove(atOffsets: offsets)
    }
}

struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(workout.name)
                .font(.headline)
            
            HStack {
                Label("\(formattedDate(workout.date))", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(formattedDuration(workout.duration))", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(workout.workoutType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 5)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        Label(formattedDate(workout.date), systemImage: "calendar")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label(formattedDuration(workout.duration), systemImage: "clock")
                            .foregroundColor(.secondary)
                    }
                    
                    Text(workout.workoutType.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                
                // Exercises
                VStack(alignment: .leading, spacing: 10) {
                    Text("Exercises")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(workout.exercises) { workoutExercise in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(workoutExercise.exercise.name)
                                .font(.headline)
                            
                            ForEach(workoutExercise.sets.indices, id: \.self) { index in
                                HStack {
                                    Text("Set \(index + 1)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    if let reps = workoutExercise.sets[index].reps {
                                        Text("\(reps) reps")
                                            .font(.subheadline)
                                    }
                                    
                                    if let weight = workoutExercise.sets[index].weight {
                                        Text("• \(Int(weight)) kg")
                                            .font(.subheadline)
                                    }
                                    
                                    if let duration = workoutExercise.sets[index].duration {
                                        Text("• \(Int(duration)) sec")
                                            .font(.subheadline)
                                    }
                                    
                                    if let distance = workoutExercise.sets[index].distance {
                                        Text("• \(Int(distance)) m")
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
                // Notes
                if let notes = workout.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text(notes)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}

struct CreateWorkoutView: View {
    @Binding var isPresented: Bool
    var onSave: (Workout) -> Void
    
    @State private var workoutName = ""
    @State private var workoutType = WorkoutType.strength
    @State private var workoutDate = Date()
    @State private var workoutDuration: Double = 45 // Default 45 minutes
    @State private var workoutNotes = ""
    @State private var selectedExercises: [WorkoutExercise] = []
    @State private var showingExercisePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $workoutName)
                    
                    Picker("Type", selection: $workoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $workoutDate)
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(Int(workoutDuration)) minutes")
                    }
                    
                    Slider(value: $workoutDuration, in: 5...180, step: 5) {
                        Text("Duration")
                    }
                }
                
                Section(header: Text("Exercises")) {
                    Button(action: {
                        showingExercisePicker = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Exercise")
                        }
                    }
                    
                    if selectedExercises.isEmpty {
                        Text("No exercises added")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(selectedExercises.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                Text(selectedExercises[index].exercise.name)
                                    .font(.headline)
                                
                                Text("\(selectedExercises[index].sets.count) sets")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteExercise)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $workoutNotes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty || selectedExercises.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(isPresented: $showingExercisePicker, selectedExercises: $selectedExercises)
            }
        }
    }
    
    func deleteExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }
    
    func saveWorkout() {
        let newWorkout = Workout(
            id: UUID(),
            name: workoutName,
            date: workoutDate,
            duration: workoutDuration * 60, // Convert to seconds
            exercises: selectedExercises,
            notes: workoutNotes.isEmpty ? nil : workoutNotes,
            workoutType: workoutType
        )
        
        onSave(newWorkout)
        isPresented = false
    }
}

struct ExercisePickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedExercises: [WorkoutExercise]
    
    @State private var searchText = ""
    @State private var selectedExercise: Exercise?
    @State private var numberOfSets = 3
    @State private var showingSetConfiguration = false
    
    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return sampleExercises
        } else {
            return sampleExercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search exercises", text: $searchText)
                        .autocapitalization(.none)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Exercise list
                List(filteredExercises) { exercise in
                    Button(action: {
                        selectedExercise = exercise
                        showingSetConfiguration = true
                    }) {
                        HStack {
                            Image(systemName: exercise.category == .cardio ? "figure.run" : "dumbbell")
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                            
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(exercise.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .sheet(isPresented: $showingSetConfiguration) {
                if let exercise = selectedExercise {
                    SetConfigurationView(
                        isPresented: $showingSetConfiguration,
                        exercise: exercise,
                        numberOfSets: $numberOfSets,
                        onSave: { workoutExercise in
                            selectedExercises.append(workoutExercise)
                            isPresented = false
                        }
                    )
                }
            }
        }
    }
}

struct SetConfigurationView: View {
    @Binding var isPresented: Bool
    let exercise: Exercise
    @Binding var numberOfSets: Int
    var onSave: (WorkoutExercise) -> Void
    
    @State private var sets: [ExerciseSet] = []
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise")) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    Stepper("Number of Sets: \(numberOfSets)", value: $numberOfSets, in: 1...10)
                        .onChange(of: numberOfSets) { newValue in
                            updateSets()
                        }
                }
                
                Section(header: Text("Sets")) {
                    ForEach(sets.indices, id: \.self) { index in
                        VStack {
                            HStack {
                                Text("Set \(index + 1)")
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            if exercise.category == .strength {
                                HStack {
                                    Text("Reps")
                                    
                                    Spacer()
                                    
                                    TextField("0", value: $sets[index].reps, format: .number)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                }
                                
                                HStack {
                                    Text("Weight (kg)")
                                    
                                    Spacer()
                                    
                                    TextField("0", value: $sets[index].weight, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                }
                            } else if exercise.category == .cardio {
                                HStack {
                                    Text("Duration (sec)")
                                    
                                    Spacer()
                                    
                                    TextField("0", value: $sets[index].duration, format: .number)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                }
                                
                                HStack {
                                    Text("Distance (m)")
                                    
                                    Spacer()
                                    
                                    TextField("0", value: $sets[index].distance, format: .number)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Configure Sets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Workout") {
                        let workoutExercise = WorkoutExercise(
                            id: UUID(),
                            exercise: exercise,
                            sets: sets,
                            notes: notes.isEmpty ? nil : notes
                        )
                        
                        onSave(workoutExercise)
                    }
                }
            }
            .onAppear {
                updateSets()
            }
        }
    }
    
    func updateSets() {
        // Preserve existing sets if possible
        if sets.count < numberOfSets {
            // Add more sets
            for _ in sets.count..<numberOfSets {
                sets.append(ExerciseSet(id: UUID()))
            }
        } else if sets.count > numberOfSets {
            // Remove excess sets
            sets = Array(sets.prefix(numberOfSets))
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(authViewModel.currentUser?.username ?? "User")
                                .font(.headline)
                            
                            Text(authViewModel.currentUser?.email ?? "email@example.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    HStack {
                        Text("Height")
                        Spacer()
                        Text("\(Int(authViewModel.currentUser?.height ?? 0)) cm")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        Text("\(Int(authViewModel.currentUser?.weight ?? 0)) kg")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Fitness Goals")) {
                    if let goals = authViewModel.currentUser?.fitnessGoals, !goals.isEmpty {
                        ForEach(goals, id: \.self) { goal in
                            Text(goal)
                        }
                    } else {
                        Text("No goals set")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        // Action to add a new goal
                    }) {
                        Label("Add Goal", systemImage: "plus")
                    }
                }
                
                Section(header: Text("Account")) {
                    Button("Edit Profile") {
                        // Action to edit profile
                    }
                    
                    Button("Settings") {
                        // Action to open settings
                    }
                    
                    Button("Sign Out") {
                        authViewModel.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Custom Modifiers
struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .keyboardType(.default) // Ensure default keyboard for password fields
    }
}

struct PasswordFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textContentType(.none) // Explicitly disable password autofill
            .keyboardType(.default)
            .privacySensitive(true) // Add privacy mask
    }
}

extension View {
    func customTextField() -> some View {
        self.modifier(TextFieldModifier())
    }
    
    func customPasswordField() -> some View {
        self.modifier(PasswordFieldModifier())
    }
}
