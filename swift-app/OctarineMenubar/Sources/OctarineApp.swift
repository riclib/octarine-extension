import SwiftUI

@main
struct OctarineApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Check if we're being run for native messaging
        // Chrome passes the extension origin as the first argument
        let args = CommandLine.arguments
        if args.count > 1 && args[1].starts(with: "chrome-extension://") {
            // Run in native messaging mode
            runNativeMessagingMode()
            exit(0)
        }
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
    
    func runNativeMessagingMode() {
        // Create a minimal clipping manager for native messaging
        let clippingManager = ClippingManager()
        let host = NativeMessagingHost(clippingManager: clippingManager)
        
        // Run the native messaging loop synchronously
        host.runSynchronously()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var nativeMessagingHost: NativeMessagingHost?
    var clippingManager: ClippingManager?
    var pomodoroTimer: PomodoroTimer?
    var iconResetTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Octarine")
            button.action = #selector(togglePopover)
        }
        
        // Initialize managers
        clippingManager = ClippingManager()
        pomodoroTimer = PomodoroTimer()
        
        // Start native messaging host
        nativeMessagingHost = NativeMessagingHost(clippingManager: clippingManager!)
        nativeMessagingHost?.start()
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: ContentView(
                clippingManager: clippingManager!,
                pomodoroTimer: pomodoroTimer!
            )
        )
        
        // Listen for successful clipping notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clippingDidSave),
            name: ClippingManager.didSaveClippingNotification,
            object: nil
        )
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    @objc func clippingDidSave() {
        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            // Change icon to success checkmark
            if let button = self?.statusItem?.button {
                button.image = NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: "Success")
            }
            
            // Cancel any existing timer
            self?.iconResetTimer?.invalidate()
            
            // Reset icon after 2 seconds
            self?.iconResetTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                if let button = self?.statusItem?.button {
                    button.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Octarine")
                }
            }
        }
    }
}