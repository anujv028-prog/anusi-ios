@echo off
title Push to GitHub for iOS IPA Build
cd /d "%~dp0"
echo ========================================================
echo      Upload ANUSI iOS App to GitHub Actions
echo ========================================================
echo.
echo 1. Go to https://github.com/new and create a new repository (name it 'anusi-ios').
echo 2. Copy the repository HTTPS URL.
echo.
set /p REPO_URL="Paste your GitHub Repo URL here: "
if "%REPO_URL%"=="" goto end

git remote remove origin 2>nul
git remote add origin %REPO_URL%
git branch -M master
echo.
echo Pushing code to GitHub...
git push -u origin master

echo.
echo ========================================================
echo Code pushed successfully!
echo Now open your repository on GitHub and click the 'Actions' tab.
echo Your iOS IPA build is compiling on Apple Mac runners!
echo ========================================================
:end
pause
