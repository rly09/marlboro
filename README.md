# 🏙️ CleanCity AI

**CleanCity AI** is a next-generation smart civic platform that connects citizens, volunteers, and authorities through intelligent, real-time coordination. Our mission is to transform urban cleanup through AI-powered waste detection and game-changing volunteer engagement.

![CleanCity AI Banner](https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?auto=format&fit=crop&w=1200&q=80)

## ✨ Features

- 📍 **Live Smart Map**: Real-time tracking of waste reports using Leaflet with clustering for high-density areas.
- 📸 **AI Waste Detection**: Upload photos directly from your camera. Our AI (simulated) analyzes the waste type and severity instantly.
- 🏆 **Gamification**: Earn points, build streaks, and unlock badges like "Eco Warrior" as you contribute to a cleaner city.
- 🤝 **Volunteer Synergy**: Claim cleanup tasks nearby and coordinate efforts through a seamless dashboard.
- 📊 **Impact Analytics**: Track your contribution and see the collective impact on the city-wide leaderboard.

## 🛠️ Technology Stack

### Frontend
- **React 18** + **Vite** for blazing fast development.
- **Tailwind CSS** with **Framer Motion** for a premium, glassmorphic UI.
- **React Leaflet** for interactive geospatial visualization.
- **Lucide React** for consistent, modern iconography.

### Backend
- **FastAPI (Python)**: High-performance asynchronous API framework.
- **SQLAlchemy**: Robust ORM for database management.
- **SQLite**: Lightweight, portable data storage.

## 🚀 Getting Started

### 1. Prerequisites
- Node.js (v18+)
- Python (3.10+)

### 2. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Create and activate virtual environment
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Unix/macOS:
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn sqlalchemy

# Run the backend
uvicorn backend.main:app --reload
```

### 3. Frontend Setup
```bash
# Install dependencies
npm install

# Run development server
npm run dev
```

## 📁 Project Structure

```text
├── src/                # Frontend source code
│   ├── components/     # Reusable UI components (GlassCard, ReportModal, etc.)
│   ├── context/        # Global state management (AppContext)
│   ├── pages/          # Main application screens (MapScreen, Dashboard)
│   └── lib/            # Utility functions and shared logic
├── backend/            # FastAPI backend logic
│   ├── uploads/        # Directory for user-reported images
│   ├── models.py       # Database schemas
│   └── main.py         # API endpoints and logic
└── public/             # Static assets
```

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---

Built with ❤️ for a cleaner, smarter city.
