import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var clippingManager: ClippingManager
    @ObservedObject var pomodoroTimer: PomodoroTimer
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab selector
            Picker("", selection: $selectedTab) {
                Text("Timer").tag(0)
                Text("Clippings").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Divider()
            
            // Tab content
            if selectedTab == 0 {
                PomodoroView(timer: pomodoroTimer)
            } else {
                ClippingsView(clippingManager: clippingManager)
            }
        }
        .frame(width: 300, height: 400)
    }
}

struct PomodoroView: View {
    @ObservedObject var timer: PomodoroTimer
    
    var body: some View {
        VStack(spacing: 20) {
            // Timer display
            Text(timer.formattedTime)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .padding()
            
            // Session type
            Text(timer.isWorkSession ? "Work Session" : "Break Time")
                .font(.headline)
                .foregroundColor(timer.isWorkSession ? .blue : .green)
            
            // Current task
            if let task = timer.currentTask {
                Text(task)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .lineLimit(2)
            }
            
            // Control buttons
            HStack(spacing: 20) {
                Button(action: {
                    if timer.isRunning {
                        timer.pause()
                    } else {
                        timer.start()
                    }
                }) {
                    Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                
                Button(action: timer.reset) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                }
                
                Button(action: timer.skip) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct ClippingsView: View {
    @ObservedObject var clippingManager: ClippingManager
    @State private var showingFolderPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Clippings")
                .font(.headline)
                .padding(.horizontal)
            
            // Folder selector
            HStack {
                Text("Folder:")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                
                Text(clippingManager.baseURL.path)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                Spacer()
                
                Button(action: {
                    showingFolderPicker = true
                }) {
                    Text("Change")
                        .font(.system(size: 11))
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            
            Divider()
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(clippingManager.recentClippings, id: \.self) { url in
                        ClippingRow(url: url)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.vertical)
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    clippingManager.updateBaseFolder(url)
                case .failure(let error):
                    print("Error selecting folder: \(error)")
                }
            }
        )
    }
}

struct ClippingRow: View {
    let url: URL
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(url.lastPathComponent.replacingOccurrences(of: ".md", with: ""))
                    .font(.system(size: 12))
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                NSWorkspace.shared.open(url)
            }) {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 12))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
           let creationDate = attributes[.creationDate] as? Date {
            return formatter.string(from: creationDate)
        }
        
        return "Unknown date"
    }
}