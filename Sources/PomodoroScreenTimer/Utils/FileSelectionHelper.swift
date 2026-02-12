//
//  FileSelectionHelper.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/16/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

class FileSelectionHelper {
    
    // MARK: Sound File Selection
    static func selectSoundFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Select Sound File"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .audio,
            UTType(filenameExtension: "wav")!,
            UTType(filenameExtension: "aiff")!,
            UTType(filenameExtension: "caf")!,
            UTType(filenameExtension: "mp3")!,
            UTType(filenameExtension: "m4a")!,
            UTType(filenameExtension: "aac")!
        ]
        
        panel.begin { response in
            DispatchQueue.main.async {
                if response == .OK, let url = panel.url {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: Image File Selection
    static func selectImageFile(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Select Background Image"
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .image,
            .jpeg,
            .png,
            .heic,
            .gif,
            .bmp,
            .tiff
        ]
        
        panel.begin { response in
            DispatchQueue.main.async {
                if response == .OK, let url = panel.url {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: File Management
    static func copyFileToAppSupport(from sourceURL: URL, subfolder: String) -> URL? {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, 
                                                           in: .userDomainMask).first else {
            return nil
        }
        
        let appFolder = appSupportURL.appendingPathComponent("Pomodoro Screen Timer")
        let targetFolder = appFolder.appendingPathComponent(subfolder)
        
        // Create directories if they don't exist
        try? FileManager.default.createDirectory(at: targetFolder, 
                                               withIntermediateDirectories: true, 
                                               attributes: nil)
        
        let fileName = sourceURL.lastPathComponent
        let targetURL = targetFolder.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        try? FileManager.default.removeItem(at: targetURL)
        
        // Copy the file
        do {
            try FileManager.default.copyItem(at: sourceURL, to: targetURL)
            return targetURL
        } catch {
            print("Failed to copy file: \(error)")
            return nil
        }
    }
    
    static func getAppSupportURL(for subfolder: String) -> URL? {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, 
                                                           in: .userDomainMask).first else {
            return nil
        }
        
        return appSupportURL.appendingPathComponent("Pomodoro Screen Timer").appendingPathComponent(subfolder)
    }
}
