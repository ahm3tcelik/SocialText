# Social Text

Social Media and Realtime Chat Application using Flutter

## Features
- Lazy Loading Data From Database
- Multiple Language
- Realtime Chat
- Firebase CRUD Operations
- Firebase Cloud Firestore, Storage and Authentication synced

## Youtube Video
[![Flutter Social Media & Realtime Chat Example Application - (Social Text)](https://img.youtube.com/vi/4D7TfZ1EenA/0.jpg)](https://www.youtube.com/watch?v=4D7TfZ1EenA)

## Project Structure
```text
 ├── assets
 |   ├── lang
 |       ├── en.json             # English translation
 |       ├── tr.json             # Turkish translation
 |    
 ├── lib
     ├── helper                  
     |   ├── app_localizations   # Multi language helper
     |   ├── ...
     |
     ├── models                  
     ├── screens                 # User Interfaces
     ├── services                
     |   ├── auth.dart           # Firebase Authenticattion Service
     |   |── database.dart       # Firebase Cloud Firestore Service
     |   |── storage.dart        # Firebase Storage Service
     |
     ├── shared                  # Common Widgets
     ├── validation              # Input Validators
     └── wrapper.dart            # User auth checker. 
```

## How to Use 

**Step 1:** Clone the repository

```
https://github.com/ahm3tcelik/SocialText.git
```

**Step 2:** Setup the Firebase

Enable Authentication and Cloud firestore

**Step 3:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```
