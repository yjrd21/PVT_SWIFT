import SwiftUI

struct FrameRateView: View {
    @ObservedObject var frameRateMonitor: FrameRateViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Frame Rate: \(frameRateMonitor.frameRate, specifier: "%.2f") Hz")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                print("Return to Home tapped")
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Return to Home")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            frameRateMonitor.startMonitoring()
            print("FrameRateView appeared, starting monitoring")
             }
        .onDisappear {
                 print("FrameRateView disappeared, stopping monitoring")
                 frameRateMonitor.stopMonitoring()
             }
    }
}
