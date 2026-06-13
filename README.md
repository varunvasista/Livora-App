# Livora

A Flutter-based digital church directory and community platform that connects churches, organizations, and users through a secure and modern digital ecosystem.

## Features

### Authentication
- User Registration & Login
- Email Verification
- Password Reset
- Secure Firebase Authentication
- Session Management

### User Accounts
- Quick Registration
- Email Verification
- Direct Access After Verification
- Personalized Dashboard

### Organization Accounts
- Organization Registration
- Church Information Submission
- Admin Approval Workflow
- Organization Verification Process

### Organization Details
Organizations can submit:
- Church Name
- Church Organizer Name
- Church Address
- Church Website
- YouTube Channel Link
- Social Media Links
- Church Images
- Related Images

### Community Features
- News & Events
- Community Posts
- Live Streams
- Church Updates
- Announcements

## Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Hosting

## Project Structure

```text
lib/
├── main.dart
├── screens/
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── verify_email_screen.dart
│   ├── home_screen.dart
│   ├── organization_details_screen.dart
│   └── organization_approval_waiting_screen.dart
│
├── services/
│   └── auth_service.dart
│
├── widgets/
│   ├── custom_button.dart
│   └── custom_textfield.dart
│
└── models/
```

## Authentication Flow

### User Flow

```text
Sign Up
   ↓
Email Verification
   ↓
Verify Email Screen
   ↓
Home Screen
```

### Organization Flow

```text
Sign Up
   ↓
Email Verification
   ↓
Organization Details Form
   ↓
Admin Approval Pending
   ↓
Organization Access
```

## Firebase Collections

### users

```json
{
  "uid": "",
  "name": "",
  "email": "",
  "accountType": "user"
}
```

### organizations

```json
{
  "organizationId": "",
  "churchName": "",
  "organizerName": "",
  "churchAddress": "",
  "churchWebsite": "",
  "youtubeLink": "",
  "socialMediaLinks": "",
  "status": "pending"
}
```

## Installation

### Clone Repository

```bash
git clone <repository-url>
cd livora
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

```bash
flutterfire configure
```

### Run Application

```bash
flutter run
```

### Build Web

```bash
flutter build web
```

## Requirements

- Flutter 3.x+
- Dart 3.x+
- Firebase Project
- Android Studio / VS Code

## UI Theme

- Dark Theme
- Responsive Design
- Modern Red & Black Interface
- Mobile & Web Support

## Future Enhancements

- Admin Dashboard
- Push Notifications
- Event Management
- Prayer Requests
- Community Messaging
- Multi-Language Support
- Analytics Dashboard

## Author

**Gayatri Pippalla**

Computer Science Engineering Student  
Flutter Developer | AI Enthusiast | Community Builder

---

**Livora — Building Stronger Church Communities Through Technology**
