# ANUSI iOS App (anusi.in)

Premium iOS Application for **[anusi.in](https://anusi.in)** with custom animated rose-gold splash screen and high-performance native WebView wrapper.

---

## 🌟 Features Included

1. **Animated Luxury Splash Screen**:
   - Features the high-resolution ANUSI rose-gold & diamond butterfly logo.
   - Smooth entrance scale & cubic fade-in.
   - Butterfly subtle hover / floating loop animation.
   - Rose gold ambient lighting effect.
   - Seamless crossfade into the website.

2. **Full iOS WebView Integration**:
   - Fast loading with top slim rose-gold progress bar.
   - Native pull-to-refresh.
   - Safe Area Inset support (iPhone Dynamic Island, Notch, Bottom Home Bar).
   - Swipe back & forward navigation gestures.
   - External deep-linking: Handles WhatsApp (`wa.me` / `whatsapp://`), UPI payment apps (`upi://`, `paytmmp://`, `phonepe://`, `gpay://`), phone calls (`tel:`), emails (`mailto:`), and Instagram natively.
   - Offline detection banner with an elegant "RETRY" button.
   - Persistent cookies and session storage for carts and customer logins.

3. **Two Complete Implementations Included**:
   - **`anusi-app`**: React Native (Expo SDK 58) — test immediately on iPhone & build `.ipa` in cloud without needing a Mac.
   - **`AnusiNativeIOS`**: Pure Swift / SwiftUI + WKWebView Xcode project with `.github/workflows/build-ipa.yml` for automated GitHub Actions IPA builds.

---

## 🚀 How to Test on iPhone Right Now (Instant 1-Minute Preview)

1. Open PowerShell and go to `anusi-app`:
   ```powershell
   cd "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios\anusi-app"
   npx expo start
   ```
2. On your iPhone:
   - Download the free **Expo Go** app from the Apple App Store.
   - Open your iPhone Camera and scan the QR code displayed in your terminal.
3. The app opens immediately on your iPhone with the animated butterfly logo splash screen and your live website!

---

## 📦 How to Generate the `.ipa` File on Windows

Since iOS requires Apple's compiler (macOS), you can generate the `.ipa` for free using either of these two methods on your Windows PC:

### Method 1: EAS Cloud Build (Easiest & Recommended)
Expo provides free cloud builders running on real Apple Macs:
1. Open PowerShell inside `anusi-app`:
   ```powershell
   cd "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios\anusi-app"
   ```
2. Log in or create a free Expo account:
   ```powershell
   npx eas-cli login
   ```
3. Run the build command:
   ```powershell
   npx eas-cli build -p ios --profile preview
   ```
4. EAS will compile your iOS `.ipa` in the cloud and give you a direct download link when it finishes!

---

### Method 2: Free GitHub Actions macOS Builder
We have already created `.github/workflows/build-ipa.yml` in this repository:
1. Create a repository on GitHub (e.g. `anusi-ios`).
2. Push this folder to GitHub:
   ```powershell
   cd "C:\Users\anujv\.gemini\antigravity\scratch\anusi-ios"
   git init
   git add .
   git commit -m "Initial commit for ANUSI iOS App"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/anusi-ios.git
   git push -u origin main
   ```
3. Go to the **Actions** tab on your GitHub repository.
4. The workflow **"Build iOS IPA (ANUSI)"** will automatically start running on a free macOS runner, compile the project, and attach `Anusi.ipa` under **Artifacts** for download!

---

## 📲 How to Install the `.ipa` on your iPhone

Once you have downloaded the `Anusi.ipa`:
- **Option A (Sideloadly / AltStore)**: Free PC tools that let you install `.ipa` files directly to your iPhone via USB or Wi-Fi using your Apple ID.
- **Option B (Scarlet / TrollStore / Enterprise)**: Direct on-device installation.
- **Option C (Apple Developer / TestFlight)**: If you have an Apple Developer account, upload directly to TestFlight for official beta testing.
