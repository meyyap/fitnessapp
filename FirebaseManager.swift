//
//  FirebaseManager.swift
//  pushpullrun
//
//  Created by Meyyappan Thenappan on 3/5/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    
    override init() {
        // Check if Firebase is already configured to avoid "Default app has already been configured" error
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        
        super.init()
        
        // Enable Firestore offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        self.firestore.settings = settings
        
        // Print debug info
        #if DEBUG
        print("Firebase initialized successfully")
        if let currentUser = auth.currentUser {
            print("User already signed in: \(currentUser.uid)")
        } else {
            print("No user currently signed in")
        }
        #endif
    }
}

// MARK: - Authentication
extension FirebaseManager {
    func createUser(email: String, password: String, username: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        #if DEBUG
        print("Attempting to create user with email: \(email)")
        #endif
        
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                #if DEBUG
                print("Firebase Auth error creating user: \(error.localizedDescription)")
                let nsError = error as NSError
                print("Error code: \(nsError.code)")
                
                // Fix for AuthErrorCode reference
                if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        print("Email already in use")
                    case .invalidEmail:
                        print("Invalid email format")
                    case .weakPassword:
                        print("Password is too weak")
                    case .networkError:
                        print("Network error - check internet connection")
                    default:
                        print("Other auth error with code: \(errorCode.rawValue)")
                    }
                }
                #endif
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create user"])
                #if DEBUG
                print("Failed to get user after successful creation")
                #endif
                completion(.failure(error))
                return
            }
            
            #if DEBUG
            print("User created successfully with UID: \(user.uid)")
            #endif
            
            // Create user profile in Firestore
            let userProfile = UserProfile(
                id: UUID(),
                username: username,
                email: email,
                joinDate: Date(),
                profileImage: nil,
                height: nil,
                weight: nil,
                fitnessGoals: []
            )
            
            self.saveUserProfile(userProfile, userId: user.uid) { result in
                switch result {
                case .success:
                    #if DEBUG
                    print("User profile created successfully in Firestore")
                    #endif
                    completion(.success(userProfile))
                case .failure(let error):
                    #if DEBUG
                    print("Error creating user profile in Firestore: \(error.localizedDescription)")
                    #endif
                    
                    // If we fail to create the profile, we should delete the auth user to maintain consistency
                    user.delete { deleteError in
                        if let deleteError = deleteError {
                            #if DEBUG
                            print("Warning: Failed to delete auth user after profile creation failure: \(deleteError.localizedDescription)")
                            #endif
                        }
                    }
                    
                    completion(.failure(error))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        #if DEBUG
        print("Attempting to sign in with email: \(email)")
        #endif
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                #if DEBUG
                print("Firebase Auth error signing in: \(error.localizedDescription)")
                #endif
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to sign in"])
                #if DEBUG
                print("Failed to get user after successful sign in")
                #endif
                completion(.failure(error))
                return
            }
            
            #if DEBUG
            print("User signed in successfully with UID: \(user.uid)")
            #endif
            
            // Fetch user profile from Firestore
            self.fetchUserProfile(userId: user.uid) { result in
                switch result {
                case .success(let userProfile):
                    #if DEBUG
                    print("User profile fetched successfully")
                    #endif
                    completion(.success(userProfile))
                case .failure(let error):
                    #if DEBUG
                    print("Error fetching user profile: \(error.localizedDescription)")
                    
                    // Check if the error is "User profile not found"
                    let nsError = error as NSError
                    if nsError.domain == "FirebaseManager" && nsError.localizedDescription == "User profile not found" {
                        print("Creating new user profile for existing auth user")
                        
                        // Create a new user profile
                        let newUserProfile = UserProfile(
                            id: UUID(),
                            username: user.email?.components(separatedBy: "@").first ?? "User",
                            email: user.email ?? "",
                            joinDate: Date(),
                            profileImage: nil,
                            height: nil,
                            weight: nil,
                            fitnessGoals: []
                        )
                        
                        // Save the new profile
                        self.saveUserProfile(newUserProfile, userId: user.uid) { saveResult in
                            switch saveResult {
                            case .success:
                                print("Created new user profile successfully")
                                completion(.success(newUserProfile))
                            case .failure(let saveError):
                                print("Failed to create new user profile: \(saveError.localizedDescription)")
                                completion(.failure(saveError))
                            }
                        }
                    } else {
                        // For other errors, just pass them through
                        completion(.failure(error))
                    }
                    #else
                    completion(.failure(error))
                    #endif
                }
            }
        }
    }
    
    func signOut() -> Result<Void, Error> {
        do {
            try auth.signOut()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getCurrentUser() -> User? {
        return auth.currentUser
    }
}

// MARK: - User Profile
extension FirebaseManager {
    func saveUserProfile(_ userProfile: UserProfile, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(userProfile)
            
            // Print debug info
            #if DEBUG
            print("Attempting to save user profile to Firestore")
            print("User ID: \(userId)")
            print("Collection path: users/\(userId)")
            #endif
            
            firestore.collection("users").document(userId).setData(data) { error in
                if let error = error {
                    #if DEBUG
                    print("Error saving user profile: \(error.localizedDescription)")
                    #endif
                    completion(.failure(error))
                } else {
                    #if DEBUG
                    print("User profile saved successfully")
                    #endif
                    completion(.success(()))
                }
            }
        } catch {
            #if DEBUG
            print("Error encoding user profile: \(error.localizedDescription)")
            #endif
            completion(.failure(error))
        }
    }
    
    func fetchUserProfile(userId: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        #if DEBUG
        print("Attempting to fetch user profile for userId: \(userId)")
        #endif
        
        firestore.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                #if DEBUG
                print("Firestore error fetching user profile: \(error.localizedDescription)")
                #endif
                completion(.failure(error))
                return
            }
            
            guard let document = document else {
                let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "User document is nil"])
                #if DEBUG
                print("User document is nil")
                #endif
                completion(.failure(error))
                return
            }
            
            if !document.exists {
                let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
                #if DEBUG
                print("User profile document does not exist for userId: \(userId)")
                #endif
                completion(.failure(error))
                return
            }
            
            do {
                #if DEBUG
                print("Document exists, attempting to decode user profile")
                #endif
                let userProfile = try document.data(as: UserProfile.self)
                #if DEBUG
                print("Successfully decoded user profile: \(userProfile.username)")
                #endif
                completion(.success(userProfile))
            } catch {
                #if DEBUG
                print("Error decoding user profile: \(error.localizedDescription)")
                if let data = document.data() {
                    print("Document data: \(data)")
                } else {
                    print("Document data is nil")
                }
                #endif
                completion(.failure(error))
            }
        }
    }
    
    func updateUserProfile(_ userProfile: UserProfile, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        saveUserProfile(userProfile, userId: userId, completion: completion)
    }
}

// MARK: - Exercises
extension FirebaseManager {
    func saveExercise(_ exercise: Exercise, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(exercise)
            firestore.collection("exercises").document(exercise.id.uuidString).setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchExercises(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        firestore.collection("exercises").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let exercises = try documents.compactMap { document -> Exercise? in
                    try document.data(as: Exercise.self)
                }
                completion(.success(exercises))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteExercise(exerciseId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.collection("exercises").document(exerciseId.uuidString).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Workouts
extension FirebaseManager {
    func saveWorkout(_ workout: Workout, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try Firestore.Encoder().encode(workout)
            firestore.collection("users").document(userId).collection("workouts").document(workout.id.uuidString).setData(data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchWorkouts(userId: String, completion: @escaping (Result<[Workout], Error>) -> Void) {
        firestore.collection("users").document(userId).collection("workouts")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                do {
                    let workouts = try documents.compactMap { document -> Workout? in
                        try document.data(as: Workout.self)
                    }
                    completion(.success(workouts))
                } catch {
                    completion(.failure(error))
                }
            }
    }
    
    func deleteWorkout(workoutId: UUID, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        firestore.collection("users").document(userId).collection("workouts").document(workoutId.uuidString).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Image Upload
extension FirebaseManager {
    func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let ref = storage.reference().child("profile_images/\(userId).jpg")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
    
    func uploadExerciseImage(_ image: UIImage, exerciseId: UUID, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let ref = storage.reference().child("exercise_images/\(exerciseId.uuidString).jpg")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
}

// MARK: - Utility Functions
extension FirebaseManager {
    /// Checks if the current user has a profile in Firestore and creates one if missing
    func ensureUserProfileExists(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let currentUser = auth.currentUser else {
            let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"])
            completion(.failure(error))
            return
        }
        
        #if DEBUG
        print("Ensuring user profile exists for user: \(currentUser.uid)")
        #endif
        
        fetchUserProfile(userId: currentUser.uid) { result in
            switch result {
            case .success(let userProfile):
                // Profile exists, return it
                completion(.success(userProfile))
            case .failure(let error):
                // Check if the error is "User profile not found"
                let nsError = error as NSError
                if nsError.domain == "FirebaseManager" && nsError.localizedDescription == "User profile not found" {
                    #if DEBUG
                    print("User profile not found, creating a new one")
                    #endif
                    
                    // Create a new profile
                    let newUserProfile = UserProfile(
                        id: UUID(),
                        username: currentUser.email?.components(separatedBy: "@").first ?? "User",
                        email: currentUser.email ?? "",
                        joinDate: Date(),
                        profileImage: nil,
                        height: nil,
                        weight: nil,
                        fitnessGoals: []
                    )
                    
                    // Save the new profile
                    self.saveUserProfile(newUserProfile, userId: currentUser.uid) { saveResult in
                        switch saveResult {
                        case .success:
                            #if DEBUG
                            print("Created new user profile successfully")
                            #endif
                            completion(.success(newUserProfile))
                        case .failure(let saveError):
                            #if DEBUG
                            print("Failed to create new user profile: \(saveError.localizedDescription)")
                            #endif
                            completion(.failure(saveError))
                        }
                    }
                } else {
                    // For other errors, just pass them through
                    completion(.failure(error))
                }
            }
        }
    }
} 