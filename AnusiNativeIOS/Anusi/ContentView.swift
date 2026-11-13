import SwiftUI

struct ContentView: View {
    @State private var isSplashFinished = false
    
    var body: some View {
        ZStack {
            // Main Website WebView (preloads in background)
            WebViewContainer(urlString: "https://anusi.in")
            
            // Flipkart / Myntra Style Animated Splash Screen
            if !isSplashFinished {
                SplashView(isFinished: $isSplashFinished)
                    .zIndex(1)
            }
        }
    }
}
