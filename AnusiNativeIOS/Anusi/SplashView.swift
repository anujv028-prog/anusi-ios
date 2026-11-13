import SwiftUI

struct SplashView: View {
    @Binding var isFinished: Bool
    
    // In-animation states (Flipkart / Myntra Pop & Bounce)
    @State private var logoScale: CGFloat = 0.55
    @State private var logoOpacity: Double = 0.3
    
    // Pulse effect
    @State private var pulseScale: CGFloat = 1.0
    
    // Out-animation states (Flipkart / Myntra Zoom & Reveal)
    @State private var outScale: CGFloat = 1.0
    @State private var splashOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Clean pristine white background
            Color.white
                .ignoresSafeArea()
            
            // Centered Logo View
            VStack {
                Spacer()
                
                logoImageView
                    .scaleEffect(logoScale * pulseScale * outScale)
                    .opacity(logoOpacity)
                    .shadow(color: Color(red: 0.85, green: 0.65, blue: 0.58).opacity(0.35), radius: 16, x: 0, y: 8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .opacity(splashOpacity)
        .onAppear {
            startFlipkartMyntraAnimation()
        }
    }
    
    // Robust image loader with multiple fallbacks
    @ViewBuilder
    private var logoImageView: some View {
        if let image = loadLogoImage() {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 270, height: 160)
        } else {
            // Safe fallback
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 270, height: 160)
        }
    }
    
    private func loadLogoImage() -> UIImage? {
        if let img = UIImage(named: "Logo") { return img }
        if let img = UIImage(named: "AppLogo") { return img }
        if let img = UIImage(named: "logo") { return img }
        if let path = Bundle.main.path(forResource: "logo", ofType: "png"), let img = UIImage(contentsOfFile: path) {
            return img
        }
        return nil
    }
    
    private func startFlipkartMyntraAnimation() {
        // 1. IN-ANIMATION: Flipkart / Myntra Signature Elastic Pop (0.0s - 0.6s)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.62, blendDuration: 0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // 2. SUBTLE HEARTBEAT PULSE (0.7s - 1.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeInOut(duration: 0.35)) {
                pulseScale = 1.04
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    pulseScale = 1.0
                }
            }
        }
        
        // 3. OUT-ANIMATION: Flipkart / Myntra Signature Zoom-Out & Dissolve (1.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.45)) {
                outScale = 1.28
                splashOpacity = 0.0
            }
            
            // Finish splash transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
                isFinished = true
            }
        }
    }
}
