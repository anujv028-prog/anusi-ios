import SwiftUI

struct ContentView: View {
    @State private var isSplashFinished = false
    
    var body: some View {
        ZStack {
            // Main Website WebView
            WebViewContainer(urlString: "https://anusi.in")
            
            // Animated Splash Screen with In & Out Animations
            if !isSplashFinished {
                SplashView(isFinished: $isSplashFinished)
                    .zIndex(1)
            }
        }
    }
}
