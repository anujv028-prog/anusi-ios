import SwiftUI

struct ContentView: View {
    @State private var isSplashFinished = false
    
    var body: some View {
        ZStack {
            // Main Website WebView
            WebViewContainer(urlString: "https://anusi.in")
                .opacity(isSplashFinished ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: isSplashFinished)
            
            // Animated Splash Screen
            if !isSplashFinished {
                SplashView(isFinished: $isSplashFinished)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
}
