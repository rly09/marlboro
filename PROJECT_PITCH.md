# CleanCity AI Project Pitch and Technical Brief

## 1. Executive Pitch

CleanCity AI is a smart civic cleanup platform that turns waste reporting and volunteer coordination into a real-time, AI-assisted workflow.

Citizens can capture a garbage report with a photo and GPS coordinates. The backend runs local YOLOv8 vision analysis and optional Cerebras AI reasoning to infer waste type and severity. Volunteers can then claim cleanup tasks, upload after-proof photos, earn points, build streaks, and move up a live leaderboard. A map-first interface keeps the entire city cleanup picture visible in one place.

The result is a practical civic operations product with three goals:

1. Detect waste faster.
2. Coordinate cleanup work more transparently.
3. Reward participation so the system stays active.

## 2. Product Story

The project is designed as a civic engagement and environmental operations tool. It combines four layers:

- Reporting: citizens submit garbage sightings with photos and location.
- Intelligence: AI analyzes the image and generates a severity insight.
- Coordination: volunteers claim nearby cleanup work and submit proof.
- Motivation: users collect points, streaks, badges, trust score growth, and leaderboard rank.

The app is especially strong as a demo because it has visible feedback loops:

- A report appears on the live map immediately.
- A volunteer claims the task and gets instant point feedback.
- A cleanup completion changes report state and updates the leaderboard.
- WebSocket events keep the UI synchronized without manual refresh.

## 3. What The Project Actually Does

The current implementation includes:

- A Flutter front end for map browsing, dashboards, reporting, and task execution.
- A FastAPI backend that stores reports and users in SQLite.
- Uploaded image storage for before/after evidence.
- YOLOv8 local inference using the bundled `yolov8n.pt` model.
- Optional Cerebras model calls for structured reasoning and severity classification.
- WebSocket updates for live report and leaderboard changes.
- A simple Hindi/English localization toggle.
- A gamified reputation system built around points, streaks, trust score, and cleanups.

## 4. Core User Flow

### Citizen flow

1. Open the app on the map screen.
2. Tap the report button.
3. Upload or capture a photo.
4. The app requests GPS and attaches coordinates.
5. The backend stores the image, runs YOLOv8, and optionally asks Cerebras for a structured summary.
6. A new report appears on the map and in the dashboard.

### Volunteer flow

1. Browse active cleanup tasks on the map.
2. Open a report card.
3. Claim the task and earn claim points.
4. Clean the site and upload an after-photo.
5. The report is marked clean, proof is stored, and cleanup points are awarded.
6. The leaderboard and stats update in real time.

### Admin / operations view

The dashboard provides a compact operational view of:

- Total reports.
- In-progress work.
- Cleaned reports.
- Trust score.
- Total cleanups.
- Local leaderboard.
- Impact summary.
- Predictive heatmap style card.

## 5. Frontend Stack

The frontend is a Flutter application and the project currently behaves like a web-first Flutter app, launched with Chrome in `run.bat`.

### Runtime and framework

- Flutter SDK: declared for Dart 3 (`>=3.0.0 <4.0.0`).
- Widget state pattern: `provider` with `ChangeNotifier`.
- Navigation: in-app shell with map and dashboard tabs plus modal sheets for actions.
- Styling: dark glassmorphic UI using a custom theme and Google Fonts.

### Frontend packages in `pubspec.yaml`

- `provider`: app-wide state management.
- `http`: REST API requests to the backend.
- `flutter_map`: interactive map rendering.
- `latlong2`: latitude/longitude types used by the map and report coordinates.
- `flutter_map_marker_cluster`: clustering support for dense marker sets.
- `geolocator`: GPS permission and position acquisition.
- `image_picker`: image capture and gallery selection.
- `google_fonts`: custom typography, currently using Outfit.
- `cached_network_image`: efficient loading of remote images.
- `animations`: extra motion utilities for richer UI transitions.
- `fl_chart`: charting support for analytics-style visualizations.
- `confetti`: celebration effects for task claim and completion moments.
- `shimmer`: loading skeleton support.
- `cupertino_icons`: iOS-style icon set.
- `web_socket_channel`: realtime synchronization with the backend.
- `shared_preferences`: stores locale preference locally.

### Frontend app structure

- `lib/main.dart`: app bootstrap, provider setup, theme, bottom navigation, and report action button.
- `lib/screens/map_screen.dart`: live map, markers, user location, and task overlay.
- `lib/screens/dashboard_screen.dart`: stats, leaderboard, impact summary, and predictive card.
- `lib/screens/report_sheet.dart`: report creation flow with image upload and GPS.
- `lib/screens/task_sheet.dart`: claim, cleanup, proof upload, and before/after comparison.
- `lib/providers/app_provider.dart`: fetches data, manages notifications, and handles websocket updates.
- `lib/providers/locale_provider.dart`: simple EN/HI translation layer.
- `lib/models/models.dart`: client-side report, stats, and leaderboard models.
- `lib/services/api_service.dart`: HTTP client for the backend endpoints.
- `lib/theme/colors.dart`: central color palette and severity/status helpers.
- `lib/widgets/*`: reusable glass cards, status pills, and toast overlay.

### UI and interaction details

The UI uses a consistent dark civic-tech look:

- Background: deep navy/black surfaces.
- Accent colors: emerald, blue, orange, red, and yellow.
- Typography: Outfit via Google Fonts.
- Motion: pulsing markers, animated counters, slide-up sheets, confetti, and loading transitions.
- Map: Carto dark tiles through `flutter_map`.
- Reports: bottom sheet flows for report creation and task execution.

## 6. Backend Stack

The backend is a FastAPI application running on Python with SQLite as the local persistence layer.

### Backend packages in `requirements.txt`

- `fastapi`: API framework and websocket handling.
- `uvicorn`: ASGI server for local development and runtime.
- `sqlalchemy`: ORM for database models and queries.
- `python-multipart`: required for file uploads in form requests.
- `cerebras-cloud-sdk`: optional AI reasoning and JSON response generation.
- `ultralytics`: YOLOv8 model loading and image inference.
- `python-dotenv`: environment variable loading from `.env`.

### Backend modules

- `backend/main.py`: all HTTP routes, websocket endpoint, seeding, and AI pipeline.
- `backend/models.py`: SQLAlchemy models for users and reports.
- `backend/schemas.py`: Pydantic response models.
- `backend/database.py`: SQLite engine, session factory, and DB dependency.
- `backend/patch_db.py`: migration helper for adding later columns to SQLite.

### Backend runtime details

- Database: `sqlite:///./cleancity.db`.
- Upload storage: `backend/uploads/`.
- Model file: `yolov8n.pt` in the repo root.
- CORS: enabled for all origins in the current development setup.
- Static file serving: uploaded images are exposed through `/api/uploads`.
- WebSocket endpoint: `/api/ws`.

## 7. Data Model

### User model

Stored fields:

- `id`
- `name`
- `is_me`
- `points`
- `streak`
- `badges`
- `trust_score`
- `total_cleanups`

Purpose:

- Represents the current user plus leaderboard users.
- Supports gamification and trust scoring.
- Stores badges as a JSON string.

### Report model

Stored fields:

- `id`
- `lat`
- `lng`
- `severity`
- `status`
- `img`
- `description`
- `aiInsight`
- `after_img`
- `claimed_by_name`

Purpose:

- Represents a waste report on the map.
- Tracks lifecycle from pending to in progress to cleaned.
- Stores before and after proof.
- Holds AI-generated insight text.

## 8. API Surface

### REST endpoints

- `GET /api/reports`: fetch all reports.
- `POST /api/reports`: create a report from latitude, longitude, description, and image upload.
- `PUT /api/reports/{id}/claim`: claim a report and award claim points.
- `POST /api/reports/{id}/complete`: submit cleanup proof and finish the task.
- `GET /api/user/stats`: fetch current user stats.
- `GET /api/leaderboard`: fetch leaderboard entries.

### WebSocket events

- `report_new`: broadcast when a new report is created.
- `report_updated`: broadcast when claim or completion changes a report.
- `leaderboard_updated`: broadcast when points or cleanup counts change.

### Static image serving

- `GET /api/uploads/{filename}`: serves uploaded before and after images.

## 9. AI and Automation Pipeline

The AI workflow is layered rather than single-step:

1. The report image is saved locally.
2. YOLOv8 attempts local object detection from `yolov8n.pt`.
3. Detected object names are summarized into a short text string.
4. If `CEREBRAS_API_KEY` exists, the app calls Cerebras chat completions.
5. Cerebras is prompted to return JSON with severity and a short insight.
6. If Cerebras is unavailable, the app still generates a fallback insight based on the detections.

This makes the app resilient:

- It still works without an AI key.
- It still works if model loading fails.
- It still provides a useful report object for the UI.

## 10. Gamification Model

The app rewards useful civic behavior with clear incentives.

### Claim points

- Claiming a report gives `+10` points.

### Cleanup points

- Low severity cleanup: `+10` points.
- Medium severity cleanup: `+25` points.
- High severity cleanup: `+50` points.

### Additional reputation signals

- Trust score increases slightly when cleanup proof is submitted.
- Total cleanups increments on each completed task.
- Streak and badges are part of the user profile shape.
- Leaderboard is sorted by points descending.

## 11. Seed Data And Demo Behavior

The backend seeds demo data automatically if the database is empty.

- Creates a current user named `Yogi`.
- Creates sample leaderboard users.
- Seeds example reports around SRM University, Kattankulathur.
- Provides a visually useful demo state immediately after startup.

This is important for demos because the app opens with:

- visible reports,
- visible points,
- visible leaderboard competition,
- and live map markers.

## 12. Run Workflow

The repo includes `run.bat` for local startup on Windows.

### What it does

1. Starts the FastAPI backend on `http://127.0.0.1:8000`.
2. Starts the Flutter web frontend on `http://localhost:5173`.

### Manual setup

Backend:

```bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r ..\requirements.txt
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Frontend:

```bash
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173
```

### Environment variable

- `CEREBRAS_API_KEY`: optional, enables the Cerebras AI insight path.

## 13. Repository Layout

```text
.
├── README.md
├── PROJECT_PITCH.md
├── requirements.txt
├── run.bat
├── yolov8n.pt
├── backend/
│   ├── database.py
│   ├── main.py
│   ├── models.py
│   ├── patch_db.py
│   ├── schemas.py
│   └── uploads/
├── frontend/
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── theme/
│   │   └── widgets/
│   └── web/
└── public/
```

## 14. Why This Project Is Strong

This project is compelling because it connects a social problem to a product loop that is easy to understand and easy to demo:

- Waste is reported with evidence.
- AI adds instant classification and insight.
- Volunteers get clear work to do.
- Proof is required before completion.
- Rewards and reputation keep the network active.

It is not just a dashboard. It is an operational system with:

- live geospatial awareness,
- asynchronous backend logic,
- image upload and storage,
- realtime state propagation,
- and a gamified civic participation model.

## 15. Short Pitch Version

CleanCity AI is a real-time civic cleanup platform that uses Flutter, FastAPI, YOLOv8, and optional Cerebras reasoning to turn waste reporting into an actionable volunteer workflow. Citizens report garbage with photos and GPS, AI classifies severity, volunteers claim tasks, submit proof, and earn points while the city map and leaderboard update live.
