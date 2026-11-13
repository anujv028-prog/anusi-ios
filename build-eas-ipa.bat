@echo off
title Build ANUSI iOS IPA
cd /d "%~dp0\anusi-app"
echo ===================================================
echo           Building ANUSI iOS IPA via EAS
echo ===================================================
echo This will build the .ipa file for your iPhone in the cloud.
echo.
npx eas-cli build -p ios --profile preview
pause
