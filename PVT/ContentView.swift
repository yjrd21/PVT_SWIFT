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
            
            }
            .onAppear {
                viewModel.stimulusVisible = false
            }
        }}}
