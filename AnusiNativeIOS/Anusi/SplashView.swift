import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    
    // In-animation states
    @State private var logoScale: CGFloat = 0.78
    @State private var logoOpacity: Double = 0.0
    @State private var logoOffsetY: CGFloat = 18
    @State private var glowOpacity: Double = 0.0
    
    // Butterfly floating breath
    @State private var floatOffset: CGFloat = 0.0
    
    // Shimmer sheen
    @State private var shimmerOffset: CGFloat = -260
    
    // Out-animation states (Exit animation)
    @State private var outScale: CGFloat = 1.0
    @State private var splashOverallOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Luxury pure white background
            Color.white
                .ignoresSafeArea()
            
            // Subtle ambient warm gold radiance in the center
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.99, green: 0.96, blue: 0.94).opacity(0.95),
                    Color.white
                ]),
                center: .center,
                startRadius: 30,
                endRadius: 340
            )
            .ignoresSafeArea()
            
            // Perfectly Centered Luxury Logo
            ZStack {
                // Soft Rose-Gold Glow
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .blur(radius: 22)
                    .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.58))
                    .opacity(glowOpacity * 0.35)
                    .scaleEffect(logoScale * outScale)
                    .offset(y: logoOffsetY + floatOffset)
                
                // Sharp Foreground Logo with metallic sheen
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .scaleEffect(logoScale * outScale)
                    .opacity(logoOpacity)
                    .offset(y: logoOffsetY + floatOffset)
                    .overlay(
                        // Moving Diamond/Metallic Shimmer Sweep
                        GeometryReader { geo in
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .frame(width: 80, height: geo.size.height * 1.6)
                            .rotationEffect(.degrees(25))
                            .offset(x: shimmerOffset)
                            .mask(
                                Image("logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 300)
                            )
                        }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .opacity(splashOverallOpacity)
        .onAppear {
            runAnimationSequence()
        }
    }
    
    private func runAnimationSequence() {
        // 1. IN-ANIMATION: Elegant scale-in and fade-in (0s - 1.1s)
        withAnimation(.easeOut(duration: 1.15)) {
            logoScale = 1.0
            logoOpacity = 1.0
            logoOffsetY = 0
            glowOpacity = 1.0
        }
        
        // 2. METALLIC SHIMMER: Sheen moves across the rose gold logo and butterfly (0.5s - 1.8s)
        withAnimation(.easeInOut(duration: 1.3).delay(0.45)) {
            shimmerOffset = 360
        }
        
        // 3. BUTTERFLY FLOAT: Subtle hover motion
        withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
            floatOffset = -5
        }
        
        // 4. OUT-ANIMATION (Exit): Logo gracefully expands & dissolves into the live website (2.4s - 3.1s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            withAnimation(.easeInOut(duration: 0.7)) {
                outScale = 1.10
                splashOverallOpacity = 0.0
            }
            
            // Finish splash after exit animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                isFinished = true
            }
        }
    }
}
