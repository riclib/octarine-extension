import Foundation

class ClippingManager: ObservableObject {
    @Published var recentClippings: [URL] = []
    
    private let fileManager = FileManager.default
    private let baseURL: URL
    private let clippingsURL: URL
    private let dailyNotesURL: URL
    
    init() {
        // Get the user's Documents directory
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        baseURL = documentsURL.appendingPathComponent("Octarine")
        clippingsURL = baseURL.appendingPathComponent("clippings")
        dailyNotesURL = baseURL.appendingPathComponent("daily")
        
        // Create directories if they don't exist
        createDirectoriesIfNeeded()
        
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
        
        // Update recent clippings
        recentClippings.insert(fileURL, at: 0)
        if recentClippings.count > 10 {
            recentClippings.removeLast()
        }
        
        // Optionally add reference to today's daily note
        addToDailyNote(clippingURL: fileURL, metadata: metadata)
    }
    
    private func sanitizeFilename(_ filename: String) -> String {
        // Remove or replace invalid characters
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        let sanitized = filename.components(separatedBy: invalidCharacters).joined(separator: "-")
        
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
            
            let clippingRef = "\n- \(timeString) - [[\(clippingURL.lastPathComponent.replacingOccurrences(of: ".md", with: ""))]] - \(metadata.url)"
            
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
}