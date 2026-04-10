# CleanCity AI

CleanCity AI is a smart civic cleanup platform built with a Flutter frontend and a FastAPI backend. It lets citizens report waste with photos and GPS, uses local YOLOv8 plus optional Cerebras reasoning to classify the report, and lets volunteers claim and complete cleanup work while the map and leaderboard update in real time.

For the full project pitch, architecture, package inventory, API surface, and data model, see [PROJECT_PITCH.md](PROJECT_PITCH.md).

## Quick Start

Run the local demo on Windows with [run.bat](run.bat). It starts the backend on `http://127.0.0.1:8000` and the Flutter web app on `http://localhost:5173`.

## Stack Snapshot

- Frontend: Flutter, Provider, flutter_map, geolocator, image_picker, web_socket_channel
- Backend: FastAPI, SQLAlchemy, SQLite, Uvicorn
- AI: Ultralytics YOLOv8, Cerebras Cloud SDK
- Storage: local SQLite database and uploaded image files in `backend/uploads/`

## Main Flow

1. Report waste with a photo and location.
2. Analyze the image locally and optionally with Cerebras.
3. Claim nearby cleanup tasks.
4. Submit after-proof photos.
5. Earn points, raise trust score, and move up the leaderboard.
