import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @StateObject private var frameRateViewModel=FrameRateViewModel()
    @Environment(\.scenePhase) private var scenePhase // Add this to observe app state changes
    
    
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
                        viewModel.startTest()
                    }
                }){
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
                viewModel.stimulusVisible = false
                viewModel.requestNotificationPermission { granted in
                    print("Notification permission status on app start: \(granted)")
                }
                viewModel.configureAudioSession() // Ensure the audio session is configured when the app starts
                viewModel.showDNDReminder() // Show the DND reminder alert
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                           if newPhase == .active {
                               viewModel.configureAudioSession() // Re-activate audio session when app becomes active
                           }
                       }
            
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Reminder"),
                    message: Text("Please enable Do Not Disturb Mode to mute notifications while conducting the test."),
                    dismissButton: .default(Text("Got it!"))
                )
            }
        }}}
