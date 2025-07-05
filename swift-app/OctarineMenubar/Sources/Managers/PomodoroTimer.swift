import Foundation
import Combine
import UserNotifications

class PomodoroTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false
    @Published var currentTask: String?
    @Published var isWorkSession = true
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    let workDuration: TimeInterval = 25 * 60 // 25 minutes
    let breakDuration: TimeInterval = 5 * 60  // 5 minutes
    
    init() {
        reset()
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func start() {
        guard !isRunning else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = isWorkSession ? workDuration : breakDuration
    }
    
    func skip() {
        // Switch between work and break
        isWorkSession.toggle()
        reset()
    }
    
    func setTask(_ task: String) {
        currentTask = task
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            sessionComplete()
            return
        }
        
        timeRemaining -= 1
    }
    
    private func sessionComplete() {
        pause()
        
        // Send notification
        let content = UNMutableNotificationContent()
        content.title = isWorkSession ? "Work session complete!" : "Break time over!"
        content.body = isWorkSession ? "Time for a break." : "Ready to work?"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
        
        // Switch session type
        isWorkSession.toggle()
        reset()
    }
    
    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}