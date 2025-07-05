import Foundation
import Combine

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
        let notification = NSUserNotification()
        notification.title = isWorkSession ? "Work session complete!" : "Break time over!"
        notification.informativeText = isWorkSession ? "Time for a break." : "Ready to work?"
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
        
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