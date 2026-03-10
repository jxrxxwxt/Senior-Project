# Detection Application

A comprehensive mobile application built with **Flutter** and **FastAPI** that leverages **YOLO AI Models** to detect, classify, and analyze bacterial specimens (Gram type and Shape) with high accuracy. Designed with a clean, Apple-inspired UI/UX.

---

## Key Features

### AI-Powered Image Analysis
*   **Dual Models:** Choose between *Specimen Model* (for mixed populations) and *Pure Culture Model* (for isolated colonies).
*   **Image:** Compare the **Original Image** vs. **Detected Image** (with YOLO Bounding Boxes).
*   **Full-Screen Viewer:** Tap on any image to view it in full screen (pinch-to-zoom) and **Save to Device Gallery**.

### Advanced Folder & History Management
*   **Persistent Folders:** Create, name, and manage custom folders. Folders remain in the database even if empty.
*   **Real-time Search:** Instantly search through analysis names, notes, and folder names.
*   **Filters:** Filter history by Date Range, Gram Type, and Bacterial Shape.
*   **Batch Operations:** Select multiple items/folders to delete them at once.

### Interactive Dashboard
*   **Statistics:** Track total analyses performed, average accuracy, and daily counts.
*   **Calendar:** View your analysis history on a weekly calendar basis.
*   **Recent Activity:** View your latest analysis results.

### Authentication & Access Control
*   **JWT Authentication:** Secure login and registration for medical personnel.
*   **Guest Mode:** Try the detection features instantly without saving history.

---

## Tech Stack

### Frontend (Mobile App)
*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Networking:** Dio

### Backend (REST API)
*   **Framework:** FastAPI (Python)
*   **Database:** SQLite + SQLAlchemy
*   **AI/ML:** Ultralytics YOLO

### CI/CD
*   **GitHub Actions:** Automated linting (`flutter analyze`, `flake8`) and dependency checks on every push.

---

## Getting Started

Follow these steps to set up and run the project locally.

### 1. Backend Setup (FastAPI)

1. Navigate to the backend directory:
   ```
   cd backend_api
   ```
2. Install the required Python dependencies:
   ```
   pip install -r requirements.txt
   ``` 
3. **IMPORTANT:** Place your trained YOLO models (`specimen_model.pt` and `pure_culture_model.pt`) inside the `backend_api/models/` directory.
4. Run the server:
   ```
   python main.py
   ```
   *The API will be available at `http://0.0.0.0:8000`*

### 2. Frontend Setup (Flutter)

1. Navigate to the Flutter project directory:
   ```
   cd detection_app
   ```
2. Update the API Base URL:
   * Open `lib/core/constants/app_constants.dart`
   * Change `baseUrl` to match your backend's IP address (e.g., `http://10.0.2.2:8000` for Android Emulator, or your computer's local IP for physical devices).
3. Install Flutter packages:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

---

## Project Structure

```text
.
├── .github/workflows/       # CI/CD GitHub Actions pipelines
├── backend_api/             # Python FastAPI Backend
│   ├── models/              # YOLO .pt files
│   ├── routers/             # API Endpoints (auth, analysis, history)
│   ├── schemas/             # Pydantic models
│   ├── database.py          # SQLAlchemy setup & DB Models
│   └── main.py              # FastAPI application entry point
│   └── requirements.txt
│
└── detection_app/           # Flutter Mobile Application
    ├── lib/
    │   ├── core/            # Theme, Colors, Constants, Utils
    │   ├── data/            # API Services, Models, Repositories
    │   ├── features/        # UI Screens (Auth, Dashboard, Detection, History)
    │   ├── providers/       # State Management
    │   └── main.dart        # Flutter entry point
    │   └── app.dart
    └── pubspec.yaml         # Dart dependencies
```
