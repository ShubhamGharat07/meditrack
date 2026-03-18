# MediTrack 🏥

<p align="center">
  <a href="https://github.com/ShubhamGharat07/meditrack/releases/download/v1.0.0/app-release.apk">
    <img src="https://img.shields.io/badge/⬇️%20Download%20APK-v1.0.0-1565C0?style=for-the-badge&logo=android&logoColor=white" alt="Download APK" height="50"/>
  </a>
</p>

MediTrack is a Flutter-based personal health management app that helps you track medicines, doctor appointments, and health records — with Firebase sync, AI assistant, and offline support.

---

## Features

- **Medicine Tracker** — Add medicines with dosage, frequency, and reminder times. Get notified daily.
- **Doctor Appointments** — Book and track upcoming appointments with reminders.
- **Health Records** — Upload and store medical documents (PDFs, images) via Firebase Storage.
- **Health Insurance** — Manage insurance policies with document upload.
- **AI Health Assistant** — Chat with Google Gemini for health queries.
- **Analytics** — Overview of your health data.
- **Emergency Screen** — Quick access to emergency contacts and info.
- **Dark / Light Mode** — Full theme support.
- **Offline Support** — SQLite local storage with Firebase cloud sync.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x |
| State Management | Provider |
| Navigation | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage) |
| Local DB | SQLite (sqflite) |
| Notifications | flutter_local_notifications |
| AI | Google Gemini API |
| Auth | Firebase Auth + Google Sign-In |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.0`
- Firebase project configured
- Google Gemini API key

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/ShubhamGharat07/meditrack.git
cd meditrack
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Create `.env` file in root**
```
GEMINI_API_KEY=your_gemini_api_key
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
```

**4. Add Firebase config**
- Download `google-services.json` → place in `android/app/`
- Update `lib/firebase_options.dart` with your Firebase project config

**5. Run the app**
```bash
flutter run
```

---

