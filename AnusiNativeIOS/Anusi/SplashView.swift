import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    
    @State private var scale: CGFloat = 0.82
    @State private var opacity: Double = 0.0
    @State private var shimmerOffset: CGFloat = -200
    @State private var butterflyOffset: CGFloat = 0
    @State private var outerGlow: Double = 0.0
    
    var body: some View {
        ZStack {
            // Elegant background
            Color.white
                .ignoresSafeArea()
            
            // Subtle luxury ambient radial glow
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.94, blue: 0.92).opacity(0.8),
                    Color.white
                ]),
                center: .center,
                startRadius: 20,
                endRadius: 280
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    // Logo Image
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 290)
                        .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.58).opacity(outerGlow), radius: 18, x: 0, y: 8)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .offset(y: butterflyOffset)
                }
                
                Spacer()
                
                // Subtle luxury tagline or progress indicator
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.78, green: 0.52, blue: 0.46)))
                        .scaleEffect(0.9)
                        .opacity(opacity)
                    
                    Text("LUXURY AWAITS")
                        .font(.system(size: 11, weight: .light, design: .serif))
                        .tracking(4)
                        .foregroundColor(Color(red: 0.60, green: 0.45, blue: 0.40))
                        .opacity(opacity * 0.85)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // 1. Smooth Fade & Scale in
            withAnimation(.easeOut(duration: 1.1)) {
                scale = 1.0
                opacity = 1.0
                outerGlow = 0.35
            }
            
            // 2. Butterfly subtle breathing float
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                butterflyOffset = -6
            }
            
            // 3. Transition to web after 2.4s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    isFinished = true
                }
            }
        }
    }
}
