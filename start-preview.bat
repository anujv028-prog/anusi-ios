@echo off
title ANUSI iOS App Preview
cd /d "%~dp0\anusi-app"
echo ===================================================
echo           ANUSI iOS App Preview (Expo)
echo ===================================================
echo 1. Make sure your iPhone has the 'Expo Go' app installed.
echo 2. Scan the QR code shown below using your iPhone camera.
echo ===================================================
npx expo start
pause
