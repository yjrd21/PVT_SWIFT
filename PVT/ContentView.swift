import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var frameRateViewModel=FrameRateViewModel()
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(viewModel.instructionText)
                    .font(.largeTitle)
                    .padding()
                
                if viewModel.stimulusVisible {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 100, height: 100)
                        .transition(.opacity)
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    viewModel.recordReaction()
                                }
                        )
                }
                
                Button(action: {
                    if viewModel.stimulusVisible {
                        viewModel.recordReaction()
                    } else {
                        viewModel.showAlert = true
                        print("Button pressed, showAlert set to true")
                    }
                }) {
                    Text(viewModel.stimulusVisible ? "Record Response" : "Start Test")
                        .padding()
                        .background(viewModel.stimulusVisible ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                if viewModel.reactionTime > 0 {
                    Text("Reaction Time in ms: \(viewModel.reactionTime, specifier: "%.2f") ms")
                        .padding()
                }
                
                if viewModel.renderingDelay > 0 {
                    Text("Rendering Delay Latency in ms: \(viewModel.renderingDelay, specifier: "%.2f") ms")
                        .padding()
                }
                
                if viewModel.touchEventHandlingLatency > 0 {
                    Text("Touch Event Handling Latency in ms: \(viewModel.touchEventHandlingLatency, specifier: "%.2f") ms")
                        .padding()
                }
                
                NavigationLink(destination: FrameRateView(frameRateMonitor: frameRateViewModel)) {
                    Text("FrameRate")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }
            .onAppear {
                print("ContentView appeared")
                viewModel.stimulusVisible = false
            }
            .onDisappear {
                print("ContentView disappeared")
            }
            .alert(isPresented: $viewModel.showAlert) {
                print("Alert is being presented")
                return Alert(
                    title: Text("Focus Mode Recommended"),
                    message: Text("We recommend enabling a Focus Mode that blocks notifications while using this app. You can create a Focus Mode in the iOS Settings under Focus."),
                    primaryButton: .default(Text("Open Settings")) {
                        viewModel.openFocusSettings()
                        print("openFocusSettings() launched")
                        viewModel.showAlert = false
                    },
                    secondaryButton: .cancel(Text("Continue")) {
                        viewModel.showAlert = false
                        viewModel.startTest()
                    }
                )
            }
        }
    }
}
