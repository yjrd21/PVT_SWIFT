import SwiftUI
import Combine
import UserNotifications
import AVFoundation





class ContentViewModel: ObservableObject {
    @Published var instructionText = "Press Start to begin the test"
    @Published var stimulusVisible = false
    @Published var reactionTime: TimeInterval = 0
    @Published var startTime: Date?
    @Published var stimulusStartTime: Date?
    @Published var timer: Timer?
    @Published var touchEventHandlingLatency: TimeInterval = 0
    @Published var renderingDelay: TimeInterval = 0
    @Published var timeBackendRedDot: Date?
    @Published var timeFrontendRedDot: Date?
    @Published var timeUserClick: Date?
    @Published var timeBackendClick: Date?
    @Published var showAlert = false


    func startTest() {
        reactionTime = 0
        nextStimulus()
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
           let center = UNUserNotificationCenter.current()
           center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
               DispatchQueue.main.async {
                   if let error = error {
                       print("Error requesting notification permission: \(error.localizedDescription)")
                       completion(false)
                   } else {
                       print("Notification permission granted: \(granted)")
                       completion(granted)
                   }
               }
           }
       }

    func showDNDReminder() {
          // Trigger the alert to remind users to enable DND mode
          showAlert = true
      }

    func configureAudioSession() {
        do {
            // Set the audio session category to 'playback' which stops other audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured to stop background music.")
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }


    func nextStimulus() {
        instructionText = "Wait for the stimulus..."
        stimulusVisible = false

        let delay = 2.0

        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            self.timeBackendRedDot = Date()
            self.showStimulus()

        }
    }

    private func showStimulus() {
        instructionText = "React!"
        stimulusVisible = true
        timeFrontendRedDot = Date()

        if let backendTime = timeBackendRedDot, let frontendTime = timeFrontendRedDot {
            renderingDelay = frontendTime.timeIntervalSince(backendTime) * 1000
        }

        startTime = Date()
    }

    func recordReaction() {
        timeUserClick = Date()

        if let userClickTime = timeUserClick {
            timeBackendClick = Date()

            if let start = startTime, let backendClickTime = timeBackendClick {
                let reactionTimeInterval = userClickTime.timeIntervalSince(start)
                reactionTime = reactionTimeInterval * 1000
                touchEventHandlingLatency = backendClickTime.timeIntervalSince(userClickTime) * 1000

                instructionText = "Reaction time: \(String(format: "%.2f", reactionTime)) ms"
                stimulusVisible = false
            }
        }
    }
}
