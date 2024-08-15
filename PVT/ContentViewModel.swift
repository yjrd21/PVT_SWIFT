import SwiftUI
import Combine
import UserNotifications




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
    @Published var isDNDActive = false
    
    
    private var frameRateMonitor = FrameRateViewModel()

    func startTest() {
        reactionTime = 0
        nextStimulus()
    }

    func openFocusSettings() {
        print("openFocusSettings() called")
        if let url = URL(string: "App-Prefs:root=FOCUS") {
            print("Attempting to open settings URL")
            UIApplication.shared.open(url) { success in
                print("UIApplication.shared.open(url) executed, success: \(success)")
            }
        } else {
            print("Invalid URL for Focus settings")
        }
    }
    
    func checkNotificationSettings(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                // Check if notifications are allowed
                let notificationsEnabled = settings.alertSetting == .enabled
                self.isDNDActive = !notificationsEnabled // Assume DND is active if notifications are not enabled
                
                print("Notifications Enabled: \(notificationsEnabled)")
                print("Assumed DND Active: \(self.isDNDActive)")
                
                completion(notificationsEnabled)
            }
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
