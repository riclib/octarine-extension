import Foundation

struct ClipMetadata {
    let title: String
    let url: String
    let author: String?
    let keywords: [String]
    let date: String
    let excerpt: String?
    let clippedAt: Date = Date()
    
    var yamlFrontmatter: String {
        var yaml = "---\n"
        yaml += "title: \"\(escapeYamlString(title))\"\n"
        yaml += "url: \"\(url)\"\n"
        yaml += "date: \(date)\n"
        
        if let author = author {
            yaml += "author: \"\(escapeYamlString(author))\"\n"
        }
        
        if !keywords.isEmpty {
            yaml += "keywords: [\(keywords.map { "\"\($0)\"" }.joined(separator: ", "))]\n"
        }
        
        yaml += "clipped_at: \(ISO8601DateFormatter().string(from: clippedAt))\n"
        
        if let excerpt = excerpt {
            yaml += "excerpt: \"\(escapeYamlString(excerpt))\"\n"
        }
        
        yaml += "---\n\n"
        return yaml
    }
    
    private func escapeYamlString(_ string: String) -> String {
        return string
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}