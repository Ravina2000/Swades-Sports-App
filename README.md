# QuickSlot (Swades Sports App)

A Flutter mobile app for booking badminton courts and turf grounds. Users browse venues, pick an hourly slot, and manage bookings. The app talks to a Dart **Shelf** REST API backed by **SQLite**.

**Production API:** `https://swades-sports-backend-production.up.railway.app`

---

## Features

- Select a demo user and browse sports venues (badminton & turf)
- View available hourly slots for any date (6 AM – 10 PM)
- Book a slot with concurrency-safe handling (slot conflicts return a clear error)
- View and cancel your bookings
- Switch users from the profile chip in the app bar

---

## Tech stack

| Layer | Stack |
|-------|--------|
| Mobile app | Flutter, Material 3, `flutter_bloc`, `http` |
| Backend | Dart Shelf, `shelf_router`, SQLite (`sqlite3`) |
| Deployment | Railway (backend), Docker |

---

## Project structure

```
swades_sports_app/
├── lib/                    # Flutter app
│   ├── config/             # API base URL configuration
│   ├── cubits/             # State management (auth, venues, bookings)
│   ├── models/             # Data models
│   ├── screens/            # UI screens
│   ├── services/           # HTTP API client
│   └── widgets/            # Reusable UI components
├── backend/                # Dart REST API
│   ├── bin/server.dart     # Server entry point
│   └── lib/                # Routes, database, seed data
└── android/ / ios/         # Platform projects
```

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.11+)
- [Dart SDK](https://dart.dev/get-dart) (for local backend)
- Android Studio or Android SDK (for APK / Android device)
- A physical Android device **or** Android emulator
- USB debugging enabled (physical device) or emulator running

Verify setup:

```bash
flutter doctor
dart --version
```

---

## Quick start (use hosted backend)

This is the fastest way to run the app — no local backend needed.

### 1. Install dependencies

```bash
cd swades_sports_app
flutter pub get
```

### 2. Run on a connected device or emulator

```bash
flutter run --dart-define=API_BASE_URL=https://swades-sports-backend-production.up.railway.app
```

> **Note:** The app defaults to the Railway URL even without `--dart-define`. Passing it explicitly is recommended for clarity.

### 3. Use the app

1. Pick a user: **Alice Sharma**, **Bob Patel**, or **Charlie Mehta**
2. Open **Venues** → tap a venue → choose a date and slot → **Book**
3. Open **My Bookings** to view or cancel bookings
4. Tap your name in the top-right chip to switch users

---

## Run with local backend (optional)

### Start the API server

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Server runs at `http://localhost:8080` by default. Health check: `GET /health` → `ok`

On **Windows (PowerShell)**:

```powershell
cd backend
dart pub get
dart run bin/server.dart
```

### Point the app at the local server

| Target | API URL |
|--------|---------|
| Android emulator | `http://10.0.2.2:8080` |
| Physical device (same Wi‑Fi) | `http://<your-pc-lan-ip>:8080` (e.g. `http://192.168.1.5:8080`) |

```bash
# Emulator example
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

> Use `http://` for local dev. For Railway, always use `https://` — `http://` breaks POST `/bookings` due to redirects.

---

## Build & install APK

### Debug APK (for testing)

```bash
flutter build apk --debug --dart-define=API_BASE_URL=https://swades-sports-backend-production.up.railway.app
```

Output:

```
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (smaller, optimized)

```bash
flutter build apk --release --dart-define=API_BASE_URL=https://swades-sports-backend-production.up.railway.app
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

### Install APK on a connected phone

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

Or copy the `.apk` file to the phone and open it (enable **Install from unknown sources** if prompted).

### Split APKs per CPU architecture (optional, smaller downloads)

```bash
flutter build apk --split-per-abi --release --dart-define=API_BASE_URL=https://swades-sports-backend-production.up.railway.app
```

Outputs are under `build/app/outputs/flutter-apk/` (`app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`, etc.).

---

## API configuration

Base URL is set in `lib/config/api_config.dart`. Override at build/run time:

```bash
--dart-define=API_BASE_URL=<your-url>
```

| Environment | Example URL |
|-------------|-------------|
| Production (Railway) | `https://swades-sports-backend-production.up.railway.app` |
| Local + emulator | `http://10.0.2.2:8080` |
| Local + physical device | `http://192.168.x.x:8080` |

The app sends the selected user ID on protected requests via the `X-User-Id` header.

---

## Demo users

| User ID | Name |
|---------|------|
| `user-1` | Alice Sharma |
| `user-2` | Bob Patel |
| `user-3` | Charlie Mehta |

---

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check |
| `GET` | `/venues` | List all venues |
| `GET` | `/venues/:id/slots?date=YYYY-MM-DD` | Slots for a venue on a date |
| `POST` | `/bookings` | Create booking (`venue_id`, `date`, `start_hour`) |
| `GET` | `/users/:userId/bookings` | List user bookings |
| `DELETE` | `/bookings/:id` | Cancel a booking |

---

## Backend tests

```bash
cd backend
dart test
```

---

## Deploy backend to Railway

The `backend/` folder includes a `Dockerfile` and `railway.toml`. Set `DB_PATH=/data/quickslot.db` and mount a volume at `/data` so bookings persist across redeploys. See `backend/.env.example`.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Infinite loading / timeout | Check internet; confirm backend is up (`/health`). For local dev, verify IP/port and firewall. |
| Booking fails on Railway | Use `https://`, not `http://`, in `API_BASE_URL`. |
| Cannot reach local backend from phone | Use your PC’s LAN IP, not `localhost`. Phone and PC must be on the same network. |
| `flutter doctor` issues | Install Android SDK, accept licenses: `flutter doctor --android-licenses` |
| Hot reload after auth/routing changes | Use hot **restart** (`R`) or full restart |

---

## Useful commands

```bash
# List connected devices
flutter devices

# Run tests (Flutter)
flutter test

# Clean build cache
flutter clean && flutter pub get

# Run backend (from backend/)
dart run bin/server.dart
```

---

## License

Private project — not published to pub.dev.
