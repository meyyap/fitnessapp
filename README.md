# PushPullRun - Workout Tracking App

PushPullRun is a comprehensive workout tracking app built with SwiftUI that allows users to track both strength training and cardio workouts.

## Features

- User authentication (sign up, login, password reset)
- Exercise library with detailed instructions
- Workout tracking with sets, reps, weights, duration, and distance
- User profiles with fitness goals
- Cloud synchronization with Firebase

## Firebase Setup

This app uses Firebase for authentication, data storage, and file storage. Follow these steps to set up Firebase for this project:

1. **Create a Firebase Project**
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the setup steps
   - Give your project a name (e.g., "PushPullRun")

2. **Register your iOS app**
   - In the Firebase console, click on the iOS icon to add an iOS app
   - Enter your app's bundle ID (e.g., "com.yourdomain.pushpullrun")
   - Download the `GoogleService-Info.plist` file
   - Add this file to your Xcode project (replace the placeholder file)

3. **Enable Authentication**
   - In the Firebase console, go to "Authentication"
   - Click "Get started"
   - Enable "Email/Password" authentication

4. **Set up Firestore Database**
   - In the Firebase console, go to "Firestore Database"
   - Click "Create database"
   - Start in production mode
   - Choose a location for your database

5. **Set up Storage**
   - In the Firebase console, go to "Storage"
   - Click "Get started"
   - Follow the setup steps

6. **Add Firebase SDK to your project**
   - In Xcode, use Swift Package Manager to add the Firebase SDK
   - Go to File > Add Packages...
   - Enter the Firebase SDK URL: `https://github.com/firebase/firebase-ios-sdk.git`
   - Select the following products:
     - FirebaseAuth
     - FirebaseFirestore
     - FirebaseStorage

## Security Rules

For Firestore Database, use these security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /users/{userId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
      
      // Allow users to read and write their own workouts
      match /workouts/{workoutId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Allow authenticated users to read all exercises
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Consider restricting this in production
    }
  }
}
```

For Storage, use these security rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /exercises/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Consider restricting this in production
    }
  }
}
```

## Data Structure

The app uses the following data structure in Firestore:

- **users/{userId}**
  - User profile information
  - **users/{userId}/workouts/{workoutId}**
    - Individual workout data

- **exercises/{exerciseId}**
  - Exercise information (shared across all users)

## Dependencies

- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- SwiftUI

## Getting Started

1. Clone the repository
2. Set up Firebase as described above
3. Open the project in Xcode
4. Build and run the app

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Troubleshooting Firebase Permissions

If you encounter a "Missing or insufficient permissions" error when creating users or accessing Firestore, you need to update your Firebase security rules.

### Firestore Rules

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`pushpullrun-274df`)
3. Navigate to Firestore Database in the left sidebar
4. Click on the "Rules" tab
5. Update the rules to the following:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read and write their own data
    match /users/{userId} {
      allow create: if request.auth != null;
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
      
      // Allow users to read and write their own workouts
      match /workouts/{workoutId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Allow authenticated users to read all exercises
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Consider restricting this in production
    }
  }
}
```

### Storage Rules

1. In the Firebase Console, navigate to Storage in the left sidebar
2. Click on the "Rules" tab
3. Update the rules to the following:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /exercises/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Consider restricting this in production
    }
  }
}
```

### Authentication

1. In the Firebase Console, navigate to Authentication in the left sidebar
2. Make sure Email/Password authentication is enabled:
   - Click on the "Sign-in method" tab
   - Ensure "Email/Password" is enabled

After updating these rules, restart your app and try creating a user again. 