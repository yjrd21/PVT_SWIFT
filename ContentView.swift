import SwiftUI



struct ContentView: View {
    @State private var instructionText = "Press Start to begin the test"
    @State private var stimulusVisible = false
    @State private var reactionTime: TimeInterval = 0
    @State private var startTime: Date?
    @State private var stimulusStartTime: Date?
    @State private var timer: Timer?
    @State private var inputLatency: TimeInterval = 0
    @State private var outputLatency: TimeInterval = 0
    @State private var timeBackendRedDot: Date?
    @State private var timeFrontendRedDot: Date?
    @State private var timeUserClick: Date?
    @State private var timeBackendClick: Date?

    var body: some View {
        VStack(spacing: 20) {
            Text(instructionText)
                .font(.largeTitle)
                .padding()

            if stimulusVisible {
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                    .transition(.opacity)
                    .gesture(
                        TapGesture()
                            .onEnded { _ in
                                recordReaction()
                            }
                    )
            }

            Button(action: {
                if stimulusVisible {
                    recordReaction()
                } else {
                    startTest()
                }
            }) {
                Text(stimulusVisible ? "Record Response" : "Start Test")
                    .padding()
                    .background(stimulusVisible ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if reactionTime > 0 {
                Text("Reaction Time in ms: \(reactionTime, specifier: "%.2f") ms")
                    .padding()
            }
            
            if outputLatency > 0 {
                Text("Output Latency in ms: \(outputLatency, specifier: "%.2f") ms")
                    .padding()
            }

            if inputLatency > 0 {
                Text("Input Latency in ms: \(inputLatency, specifier: "%.2f") ms")
                    .padding()
            }
        }
        .onAppear {
            stimulusVisible = false
        }
    }

    private func startTest() {
        reactionTime = 0
        nextStimulus()
    }

    private func nextStimulus() {
        instructionText = "Wait for the stimulus..."
        stimulusVisible = false

        let delay = 2.0
        
        // Schedule code to run at specific interval
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            timeBackendRedDot = Date()
            showStimulus()
        }
    }

    private func showStimulus() {
        instructionText = "React!"
        stimulusVisible = true
        timeFrontendRedDot = Date()
        
        // Calculate output latency
        if let backendTime = timeBackendRedDot, let frontendTime = timeFrontendRedDot {
            outputLatency = frontendTime.timeIntervalSince(backendTime) * 1000
        }
        
        // Set the reference point for the timer, called in recordReaction()
        startTime = Date()
    }

    private func recordReaction() {
        // Capture the time when the user clicks
        timeUserClick = Date()
        
        if let userClickTime = timeUserClick {
            // Simulate the backend registering the click
            timeBackendClick = Date()
            
            if let start = startTime, let backendClickTime = timeBackendClick {
                let reactionTimeInterval = userClickTime.timeIntervalSince(start)
                reactionTime = reactionTimeInterval * 1000
                
                // Calculate input latency
                inputLatency = backendClickTime.timeIntervalSince(userClickTime) * 1000
                
                instructionText = "Reaction time: \(String(format: "%.2f", reactionTime)) ms"
                stimulusVisible = false
                nextStimulus() // Go to the next stimulus or end the test if done
            }
        }
    }
}
