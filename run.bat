@echo off
echo ================================
echo   CleanCity AI - Starting Up
echo ================================

REM Start the FastAPI backend
echo [1/2] Starting Python backend (http://127.0.0.1:8000)...
start "CleanCity Backend" cmd /k "cd backend && ..\venv\Scripts\python.exe -m uvicorn main:app --reload --host 127.0.0.1 --port 8000"

timeout /t 3 /nobreak > nul

REM Start the Flutter web frontend
echo [2/2] Starting Flutter Web frontend...
start "CleanCity Frontend" cmd /k "cd frontend && flutter run -d chrome --web-port 5173"

echo.
echo Both services are starting...
echo   Backend:  http://127.0.0.1:8000
echo   Frontend: http://localhost:5173
echo.
