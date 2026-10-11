@echo off
cd /d "%~dp0\..\backend"
echo Starting Fooding API...
start "Fooding API" cmd /k node src\index.js
timeout /t 2 /nobreak >nul
adb reverse tcp:3000 tcp:3000
echo.
echo Backend: http://127.0.0.1:3000
echo USB reverse: tcp:3000
echo Phone pe app/APK kholo.
pause
