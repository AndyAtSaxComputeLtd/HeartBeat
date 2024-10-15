import SwiftUI

struct ContentView: View {
    @ObservedObject var heartRateManager = HeartRateManager()

    @State private var scale: CGFloat = 1.0
    @State private var animationDuration: Double = 1.0
    
    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
                .scaleEffect(scale)
                .frame(width: 100, height: 100)
                .onChange(of: heartRateManager.heartRate) {
                    animateHeartBeat(rate: heartRateManager.heartRate)
                }
            
            Text("Heart Rate: \(Int(heartRateManager.heartRate)) BPM")
                .font(.headline)
                .padding()
        }
        .onAppear {
            animateHeartBeat(rate: heartRateManager.heartRate)
        }
    }
    
    private func animateHeartBeat(rate: Double) {
        // Calculate the duration based on heart rate in beats per minute
        let bpm = rate > 0 ? rate : 60.0 // Default to 60 BPM if no reading
        animationDuration = 60.0 / bpm
        
        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
            self.scale = 1.2
        }
        
        // Reset scale after each beat
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.scale = 1.0
        }
    }
}
