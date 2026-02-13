//
//  SystemSound.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import Foundation

struct SystemSounds: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
    
    // Helper for UI display
    var displayName: String {
        name
    }
    
    // MARK: Static Access
    
    // Loads sounds at app launche, preventing lag in Settings view.
    static let systemSounds: [SystemSounds] = loadAvailableSystemSounds()
}

// MARK: Loading Logic
extension SystemSounds {
    private static func loadAvailableSystemSounds() -> [SystemSounds] {
        let fileManager = FileManager.default
        
        let systemLibrary = URL(fileURLWithPath: "/System/Library/PrivateFrameworks/ToneLibrary.framework/Versions/A/Resources/Ringtones/")
        // Use the modern API for user directory
        let userLibrary = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Ringtones")
        
        // Order matters: User sounds will override System sounds if names match
        let directories = [systemLibrary, userLibrary]
        
        var sounds: [String: SystemSounds] = [:]
        let allowedExtensions = Set(["m4r", "aiff", "wav", "caf", "m4a"])
        
        for dir in directories {
            // Skip scanning if the folder doesn't exist (e.g. ~/Library/Sounds is often empty/missing)
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: dir.path, isDirectory: &isDir), isDir.boolValue else {
                continue
            }

            guard let fileURLs = try? fileManager.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }
            
            for url in fileURLs {
                if allowedExtensions.contains(url.pathExtension.lowercased()) {
                    let name = url.deletingPathExtension().lastPathComponent
                    // Store in dictionary to handle deduplication automatically
                    sounds[name] = SystemSounds(name: name, url: url)
                }
            }
        }
        
        return sounds.values.sorted { $0.name < $1.name }
    }
}
