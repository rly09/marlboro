@echo off
echo ==============================================
echo Installing Dependencies and Starting CleanCity
echo ==============================================

echo [1/3] Installing Node.js dependencies...
call npm install

echo [2/3] Installing Python dependencies...
python -m pip install -r requirements.txt

echo [3/3] Starting Backend and Frontend...
start cmd /k "python -m uvicorn backend.main:app --reload"
start cmd /k "npm run dev"

echo Done! The app should open momentarily in your browser.
