import SwiftUI
import Cocoa

@main
struct OctarineApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Check if we're being run for native messaging
        // Chrome passes the extension origin as the first argument
        let args = CommandLine.arguments
        if args.count > 1 && args[1].starts(with: "chrome-extension://") {
            // Check if another instance is already running
            if NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!).first(where: { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }) != nil {
                // Another instance is running, forward the message
                handleNativeMessagingAsClient()
            } else {
                // No other instance, we become the main app
                // Continue normal initialization, the AppDelegate will handle native messaging
            }
        }
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
    
    func handleNativeMessagingAsClient() {
        // Read the native message
        let input = FileHandle.standardInput
        let output = FileHandle.standardOutput
        
        // Read length (4 bytes)
        let lengthData = input.readData(ofLength: 4)
        guard lengthData.count == 4 else {
            exit(1)
        }
        
        let length = lengthData.withUnsafeBytes { $0.load(as: UInt32.self) }
        
        // Read message
        let messageData = input.readData(ofLength: Int(length))
        
        // Forward to main instance via distributed notification
        let notificationName = NSNotification.Name("com.octarine.clipper.nativeMessage")
        DistributedNotificationCenter.default().postNotificationName(
            notificationName,
            object: nil,
            userInfo: ["message": messageData.base64EncodedString()],
            deliverImmediately: true
        )
        
        // Send success response back to Chrome
        let response: [String: Any] = ["success": true, "message": "Forwarded to main instance"]
        if let responseData = try? JSONSerialization.data(withJSONObject: response),
           responseData.count < 1024 * 1024 {
            var responseLength = UInt32(responseData.count)
            let lengthData = Data(bytes: &responseLength, count: 4)
            output.write(lengthData)
            output.write(responseData)
        }
        
        exit(0)
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
        // Prevent the app from terminating when last window closes
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Octarine")
            button.action = #selector(togglePopover)
        }
        
        // Initialize managers
        clippingManager = ClippingManager()
        pomodoroTimer = PomodoroTimer()
        
        // Check if we were launched for native messaging
        let args = CommandLine.arguments
        if args.count > 1 && args[1].starts(with: "chrome-extension://") {
            // We're the first instance launched by Chrome
            // Start native messaging host
            nativeMessagingHost = NativeMessagingHost(clippingManager: clippingManager!)
            nativeMessagingHost?.start()
        }
        
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
        
        // Listen for distributed notifications from other instances
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleDistributedNativeMessage(_:)),
            name: NSNotification.Name("com.octarine.clipper.nativeMessage"),
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
    
    @objc func handleDistributedNativeMessage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let messageBase64 = userInfo["message"] as? String,
              let messageData = Data(base64Encoded: messageBase64) else {
            return
        }
        
        do {
            // Parse the message
            let message = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any]
            
            // Process it through our native messaging handler
            if let type = message?["type"] as? String,
               type == "clip",
               let content = message?["content"] as? String,
               let metadata = message?["metadata"] as? [String: Any] {
                
                let clipMetadata = ClipMetadata(
                    title: (metadata["title"] as? String ?? "Untitled").trimmingCharacters(in: .whitespacesAndNewlines),
                    url: metadata["url"] as? String ?? "",
                    author: metadata["author"] as? String,
                    keywords: metadata["keywords"] as? [String] ?? [],
                    date: metadata["date"] as? String ?? ISO8601DateFormatter().string(from: Date()),
                    excerpt: metadata["excerpt"] as? String
                )
                
                try clippingManager?.saveClipping(content: content, metadata: clipMetadata)
            }
        } catch {
            print("Failed to process distributed native message: \(error)")
        }
    }
}