//
//  WelcomeView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/14/25.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct WelcomeView: View {
    @State private var recentDocuments: [URL] = []
    @Environment(\.dismiss) private var dismiss
    private var color = Color(light: .white, dark: Color(rgba: 0x1819_1dff))
    private var listColor = Color(light: Color(rgba: 0xf7f7_f9ff), dark: Color(rgba: 0x2526_2aff))

    var body: some View {
        HStack(alignment:.top, spacing: 20) {
                VStack(alignment: .center, spacing: 20) {
                    if let image = getAppIcon() {
                        Image(nsImage: image)
                            .imageScale(.large)
                    }
                    Text(getAppName()) // App name
                        .font(.largeTitle)
                        .bold()
                    Text(getAppVersion()) // App version (fetch dynamically)
                        .font(.title)
                        .foregroundColor(.secondary)
                    Button() {
                        let panel = NSOpenPanel()
                        panel.canChooseDirectories = false
                        panel.allowedContentTypes = [
                            UTType(filenameExtension: "md")!,
                            UTType(filenameExtension: "mkdn")!
                        ]
                        panel.allowsMultipleSelection = false
                        
                        if panel.runModal() == .OK, let url = panel.url {
                            // Open the selected document
                            NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, _ in
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Open Document")
                    }
                    .tint(Color(
                        light: Color(rgba: 0xf7f7_f9ff),
                        dark: Color(rgba: 0x2526_2aff)
                    ))
                    Button() {
                        NSDocumentController.shared.newDocument(nil)
                        dismiss()
                    } label: {
                        Text("Create New Document")
                    }
                    .tint(Color(
                        light: Color(rgba: 0xf7f7_f9ff),
                        dark: Color(rgba: 0x2526_2aff)
                    ))
                }
                .frame(maxWidth: 300, maxHeight: .infinity)
                Divider()
            VStack(alignment: .leading, spacing: 15) {
               if recentDocuments.isEmpty {
                   Text("No recent files")
                       .italic()
               } else {
                    List(recentDocuments, id: \.self) { file in
                        Label(file.lastPathComponent, systemImage: "richtext.page.fill")
                            .onTapGesture {
                                NSDocumentController.shared.openDocument(withContentsOf: file, display: true) { _, _, _ in }
                            }
                    }
               }
            }
            .frame(maxWidth: 600, maxHeight: .infinity)
        }
        .onAppear {
            loadRecentFiles()
        }
        .frame(width: 700, height: 400)
        .padding(20)
        .background(color)
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .buttonStyle(mdEditorButtonStyle())
    }

    // MARK: Load Recent Files
    private func loadRecentFiles() {
        // Fetch recent documents from the system
        recentDocuments = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: Get App Info
    private func getAppName() -> String {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return buildNumber
        }
        return "Unknown"
    }
    private func getAppIcon() -> NSImage? {
        if let icon = NSImage(named: "AppIcon") {
            return icon
        }
        return nil
    }
    private func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }

}

#Preview{
    WelcomeView()
}
