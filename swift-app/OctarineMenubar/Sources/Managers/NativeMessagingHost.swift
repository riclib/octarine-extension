import Foundation

class NativeMessagingHost {
    private let clippingManager: ClippingManager
    
    init(clippingManager: ClippingManager) {
        self.clippingManager = clippingManager
    }
    
    func start() {
        // Read from stdin in a background thread
        DispatchQueue.global(qos: .background).async {
            self.readMessages()
        }
    }
    
    func runSynchronously() {
        // For native messaging mode, run synchronously
        readMessages()
    }
    
    private func readMessages() {
        let stdin = FileHandle.standardInput
        
        // Log to stderr for debugging (stdout is used for responses)
        fputs("[NativeMessaging] Starting to read messages\n", stderr)
        
        while true {
            // Read the message length (4 bytes)
            let lengthData = stdin.readData(ofLength: 4)
            guard lengthData.count == 4 else { 
                fputs("[NativeMessaging] Chrome disconnected, but app will stay resident\n", stderr)
                // Don't exit - just stop reading messages
                return
            }
            
            let length = lengthData.withUnsafeBytes { $0.load(as: UInt32.self) }
            guard length > 0 && length < 1_048_576 else { continue } // 1MB limit
            
            // Read the message
            let messageData = stdin.readData(ofLength: Int(length))
            guard messageData.count == Int(length) else { continue }
            
            // Parse the JSON message
            do {
                if let message = try JSONSerialization.jsonObject(with: messageData) as? [String: Any] {
                    handleMessage(message)
                }
            } catch {
                sendError("Failed to parse message: \(error)")
            }
        }
    }
    
    private func handleMessage(_ message: [String: Any]) {
        guard let type = message["type"] as? String else {
            sendError("Missing message type")
            return
        }
        
        switch type {
        case "clip":
            handleClipMessage(message)
        default:
            sendError("Unknown message type: \(type)")
        }
    }
    
    private func handleClipMessage(_ message: [String: Any]) {
        guard let content = message["content"] as? String,
              let metadata = message["metadata"] as? [String: Any] else {
            sendError("Invalid clip message format")
            return
        }
        
        do {
            let clipMetadata = ClipMetadata(
                title: (metadata["title"] as? String ?? "Untitled").trimmingCharacters(in: .whitespacesAndNewlines),
                url: metadata["url"] as? String ?? "",
                author: metadata["author"] as? String,
                keywords: metadata["keywords"] as? [String] ?? [],
                date: metadata["date"] as? String ?? ISO8601DateFormatter().string(from: Date()),
                excerpt: metadata["excerpt"] as? String
            )
            
            try clippingManager.saveClipping(content: content, metadata: clipMetadata)
            sendResponse(["success": true, "message": "Clipping saved successfully"])
        } catch {
            sendError("Failed to save clipping: \(error)")
        }
    }
    
    private func sendResponse(_ response: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: response)
            sendData(data)
        } catch {
            // Can't send error about error sending, just log it
            print("Failed to send response: \(error)")
        }
    }
    
    private func sendError(_ error: String) {
        sendResponse(["success": false, "error": error])
    }
    
    private func sendData(_ data: Data) {
        var length = UInt32(data.count)
        let lengthData = Data(bytes: &length, count: 4)
        
        FileHandle.standardOutput.write(lengthData)
        FileHandle.standardOutput.write(data)
    }
}