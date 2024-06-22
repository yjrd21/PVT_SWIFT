import SwiftUI
import AVFoundation

import QuartzCore

class FrameRateMonitor: ObservableObject {
    @Published var frameRate: Double = 0
    
    //CADisplaylink is a high precision timer that allows applications to synchronize it's drawings with the display's refresh rate
    //i.e: It links the app's rendering to the display's refresh rate
    private var displayLink: CADisplayLink?

    private var stimulusCallback: (() -> Void)?
    
    init() {
        startDisplayLink()
    }

    private func startDisplayLink() {
        // The method 'updateFrameRate' will be called everytime the display is refreshed
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrameRate))
        
        // A run loop is an event processing loop that manages the timing and execution of tasks in an application
        // By Adding CADisplayLink to a run loop, We are scheduling it to call it's target method at the display's refresh rate (Sync successful)
        displayLink?.add(to: .main, forMode: .default)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateFrameRate(displayLink: CADisplayLink) {
        // obtain realtime frameRate value, store it as a variable 'frameRate'
        frameRate = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
    }
    
    func startStimulusDisplayLink(callback: @escaping () -> Void) {
        // callback variable is a function.
        // I pass the function that renders the red dot here
            stimulusCallback = callback
            displayLink = CADisplayLink(target: self, selector: #selector(showStimulus))
            displayLink?.add(to: .main, forMode: .default)
        }

    @objc private func showStimulus() {
            stimulusCallback?()
            stopStimulusDisplayLink()
        }

    private func stopStimulusDisplayLink() {
            displayLink?.invalidate()
            displayLink = nil
        }

    deinit {
        //deinit is called when the class 'FrameRateMonitor' is deallocated, in this case - ContentView
        stopDisplayLink()
        print(frameRate )
    }
}
import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var instructionText = "Press Start to begin the test"
    @State private var stimulusVisible = false
    @State private var reactionTime: TimeInterval = 0
    @State private var startTime: Date?
    @State private var stimulusStartTime: Date?
    @State private var timer: Timer?
    @State private var touchEventHandlingLatency: TimeInterval = 0
    @State private var renderingDelay: TimeInterval = 0
    @State private var timeBackendRedDot: Date?
    @State private var timeFrontendRedDot: Date?
    @State private var timeUserClick: Date?
    @State private var timeBackendClick: Date?
    
    // @StateObject attribute is used to create and manage the lifecycle of an observable object.
    // The object is created when the view is initialized and is destroyed when the view is deallocated.
    @StateObject private var frameRateMonitor = FrameRateMonitor()
   
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
            
            if renderingDelay > 0 {
                Text("Rendering Delay Latency in ms: \(renderingDelay, specifier: "%.2f") ms")
                    .padding()
            }

            if touchEventHandlingLatency > 0 {
                Text("Touch Event Handling Latency in ms: \(touchEventHandlingLatency, specifier: "%.2f") ms")
                    .padding()
            }
            
            Text("Frame Rate: \(frameRateMonitor.frameRate, specifier: "%.2f") Hz")
                .padding()
        }
        .onAppear {
            stimulusVisible = false
        }
    }

    private func startTest() {
        // Enable "Do Not Disturb" mode
        do {
             try AVAudioSession.sharedInstance().setCategory(.ambient)
             try AVAudioSession.sharedInstance().setActive(true)
         } catch {
            print("Failed to enable Do Not Disturb mode: \(error)")
        }
        
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
            
            //Sync display of red dot with frameRate
            frameRateMonitor.startStimulusDisplayLink {
                
                // Pass showStimulus() method as a callback function in frameRateMonitor
                showStimulus()
            }
        }
    }

    private func showStimulus() {
        instructionText = "React!"
        stimulusVisible = true
        timeFrontendRedDot = Date()
        
        // Calculate rendering delay (output latency)
        if let backendTime = timeBackendRedDot, let frontendTime = timeFrontendRedDot {
            renderingDelay = frontendTime.timeIntervalSince(backendTime) * 1000
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
                
                // Calculate touch event handling (input latency)
                touchEventHandlingLatency = backendClickTime.timeIntervalSince(userClickTime) * 1000
                
                instructionText = "Reaction time: \(String(format: "%.2f", reactionTime)) ms"
                stimulusVisible = false
//                nextStimulus() // Go to the next stimulus or end the test if done
            }
        }
    }
}
