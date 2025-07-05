import Foundation

class ClippingManager: ObservableObject {
    @Published var recentClippings: [URL] = []
    @Published private(set) var baseURL: URL
    
    // Notification for successful clipping
    static let didSaveClippingNotification = Notification.Name("ClippingManager.didSaveClipping")
    
    private let fileManager = FileManager.default
    private var clippingsURL: URL
    private var dailyNotesURL: URL
    
    init() {
        // Load saved path from UserDefaults
        let tempBaseURL: URL
        if let savedPath = UserDefaults.standard.string(forKey: "OctarineBasePath"),
           let savedURL = URL(string: savedPath),
           fileManager.fileExists(atPath: savedURL.path) {
            tempBaseURL = savedURL
        } else {
            // Check for existing Octarine folder in home directory first
            let homeURL = fileManager.homeDirectoryForCurrentUser
            let homeOctarineURL = homeURL.appendingPathComponent("Octarine")
            
            // Use ~/Octarine if it exists, otherwise ~/Documents/Octarine
            if fileManager.fileExists(atPath: homeOctarineURL.path) {
                tempBaseURL = homeOctarineURL
            } else {
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                tempBaseURL = documentsURL.appendingPathComponent("Octarine")
            }
        }
        
        // Set baseURL
        self.baseURL = tempBaseURL
        
        // Check for capitalized Daily folder
        let capitalDailyURL = tempBaseURL.appendingPathComponent("Daily")
        if fileManager.fileExists(atPath: capitalDailyURL.path) {
            self.dailyNotesURL = capitalDailyURL
        } else {
            self.dailyNotesURL = tempBaseURL.appendingPathComponent("daily")
        }
        
        self.clippingsURL = tempBaseURL.appendingPathComponent("clippings")
        
        // Create directories if they don't exist
        createDirectoriesIfNeeded()
        
        // Log paths for debugging
        print("[ClippingManager] Using paths:")
        print("  Base: \(baseURL.path)")
        print("  Clippings: \(clippingsURL.path)")
        print("  Daily Notes: \(dailyNotesURL.path)")
        
        // Load recent clippings
        loadRecentClippings()
    }
    
    private func createDirectoriesIfNeeded() {
        do {
            try fileManager.createDirectory(at: clippingsURL, withIntermediateDirectories: true)
            try fileManager.createDirectory(at: dailyNotesURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to create directories: \(error)")
        }
    }
    
    func saveClipping(content: String, metadata: ClipMetadata) throws {
        // Create filename from date and title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: metadata.clippedAt)
        
        // Sanitize title for filename
        let sanitizedTitle = sanitizeFilename(metadata.title)
        let filename = "\(dateString) \(sanitizedTitle).md"
        
        // Create the full content with frontmatter
        let fullContent = metadata.yamlFrontmatter + "# \(metadata.title)\n\n" + content
        
        // Save to file
        let fileURL = clippingsURL.appendingPathComponent(filename)
        try fullContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Update recent clippings on main thread since it's @Published
        DispatchQueue.main.async { [weak self] in
            self?.recentClippings.insert(fileURL, at: 0)
            if let count = self?.recentClippings.count, count > 10 {
                self?.recentClippings.removeLast()
            }
        }
        
        // Optionally add reference to today's daily note
        addToDailyNote(clippingURL: fileURL, metadata: metadata)
        
        // Post notification for successful save
        NotificationCenter.default.post(name: ClippingManager.didSaveClippingNotification, object: nil)
    }
    
    private func sanitizeFilename(_ filename: String) -> String {
        // Trim whitespace first
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove or replace invalid characters
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        let sanitized = trimmed.components(separatedBy: invalidCharacters).joined(separator: "-")
        
        // Limit length
        let maxLength = 50
        if sanitized.count > maxLength {
            let index = sanitized.index(sanitized.startIndex, offsetBy: maxLength)
            return String(sanitized[..<index])
        }
        
        return sanitized
    }
    
    private func addToDailyNote(clippingURL: URL, metadata: ClipMetadata) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let dailyNoteURL = dailyNotesURL.appendingPathComponent("\(dateString).md")
        
        do {
            var content: String
            
            // Read existing content or create new
            if fileManager.fileExists(atPath: dailyNoteURL.path) {
                content = try String(contentsOf: dailyNoteURL)
            } else {
                content = "# Daily Note - \(dateString)\n\n## Tasks\n\n## Notes\n\n"
            }
            
            // Add clippings section if it doesn't exist
            if !content.contains("## Clippings") {
                content += "\n## Clippings\n"
            }
            
            // Add the new clipping reference
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            let timeString = timeFormatter.string(from: metadata.clippedAt)
            
            // Include the clippings folder in the link
            let fileNameWithoutExtension = clippingURL.lastPathComponent.replacingOccurrences(of: ".md", with: "")
            let clippingRef = "\n- \(timeString) - [[clippings/\(fileNameWithoutExtension)]] - \(metadata.url)"
            
            // Find the clippings section and add to it
            if let range = content.range(of: "## Clippings") {
                let insertIndex = content.index(range.upperBound, offsetBy: 1)
                content.insert(contentsOf: clippingRef, at: insertIndex)
            }
            
            try content.write(to: dailyNoteURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to update daily note: \(error)")
        }
    }
    
    private func loadRecentClippings() {
        do {
            let files = try fileManager.contentsOfDirectory(
                at: clippingsURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            let sortedFiles = files
                .filter { $0.pathExtension == "md" }
                .sorted { url1, url2 in
                    let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    return date1 > date2
                }
            
            recentClippings = Array(sortedFiles.prefix(10))
        } catch {
            print("Failed to load recent clippings: \(error)")
        }
    }
    
    func updateBaseFolder(_ newURL: URL) {
        // Save the new path
        UserDefaults.standard.set(newURL.absoluteString, forKey: "OctarineBasePath")
        
        // Update properties
        baseURL = newURL
        
        // Check for capitalized Daily folder in new location
        let capitalDailyURL = baseURL.appendingPathComponent("Daily")
        if fileManager.fileExists(atPath: capitalDailyURL.path) {
            dailyNotesURL = capitalDailyURL
        } else {
            dailyNotesURL = baseURL.appendingPathComponent("daily")
        }
        
        clippingsURL = baseURL.appendingPathComponent("clippings")
        
        // Create directories if needed
        createDirectoriesIfNeeded()
        
        // Log the change
        print("[ClippingManager] Updated base folder to: \(baseURL.path)")
        
        // Reload clippings from new location
        loadRecentClippings()
    }
}