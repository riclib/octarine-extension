import SwiftUI

@main
struct OctarineApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var nativeMessagingHost: NativeMessagingHost?
    var clippingManager: ClippingManager?
    var pomodoroTimer: PomodoroTimer?
    
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
}