//
//  ImagePickerRow.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 2/12/26.
//

import SwiftUI

struct ImagePickerRow: View {
    let label: String
    @Binding var path: String
    @Binding var imageName: String
    
    var body: some View {
        SettingsGridRow(label) {
            if path.isEmpty {
                Button("Select Image...") {
                    selectAndCopyImage()
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(URL(fileURLWithPath: path).lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Button("Change") { selectAndCopyImage() }
                        Button("Remove") {
                            path = ""
                            imageName = ""
                        }
                    }
                }
            }
        }
    }
    
    private func selectAndCopyImage() {
        // Grab the current window from the NSApplication
        let currentWindow = NSApp.windows.first { $0.isKeyWindow }
        
        FileSelectionHelper.selectImageFile(in: currentWindow) { url in
            guard let url,
                  let copiedURL = FileSelectionHelper.copyFileToAppSupport(from: url, subfolder: "Images")
            else { return }
            
            DispatchQueue.main.async {
                self.path = copiedURL.path
                self.imageName = copiedURL.path
            }
        }
    }
}
