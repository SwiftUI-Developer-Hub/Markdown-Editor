//
//  WelcomeView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/14/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct MarkdownWelcomeView: View {
    @State private var recentDocuments: [URL] = []
    @Environment(\.dismiss) private var dismiss
    @State private var showFileImporter: Bool = false
    @Environment(\.newDocument) private var newDocument
    @Environment(\.openDocument) private var openDocument
    private var markdownTypes: [UTType] = [
        .md, .mkd, .mkdn, .mdwn, .mdown, .mdtxt, .mdtext, .markdown, .plainText
    ]
    private var color = Color(light: .white, dark: Color(rgba: 0x1819_1dff))
    private var listColor = Color(light: Color(rgba: 0xf7f7_f9ff), dark: Color(rgba: 0x2526_2aff))
    private var buttonColor = Color(light: Color(rgba: 0xf7f7_f9ff), dark: Color(rgba: 0x2526_2aff))

    var body: some View {
        HStack(alignment:.top, spacing: .zero) {
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
                        showFileImporter = true
                    } label: {
                        Text("Open Document")
                    }

                    Button() {
                        dismiss()
                        newDocument(MarkdownFile())
                    } label: {
                        Text("Create New Document")
                    }
                }
                .padding(.trailing)
                .frame(maxWidth: 800, maxHeight: .infinity)
                Divider()
            VStack(alignment: .center) {
                if recentDocuments.isEmpty {
                    ContentUnavailableView(
                        label: {
                            Label("No Recent Files", systemImage: "clock.arrow.circlepath")
                        },
                        description: {
                            Text("Your recently opened documents will appear here.")
                        }
                    )
                } else {
                    List(
                        recentDocuments.filter { FileManager.default.fileExists(atPath: $0.path) },
                        id: \.self
                    ) { file in
                        Button {
                            Task {
                                do {
                                    _ = try await openDocument(at: file)
                                    dismiss()
                                } catch {
                                    print("Failed to open document:", error.localizedDescription)
                                }
                            }
                        } label: {
                            Label(file.lastPathComponent, systemImage: "doc.richtext.fill")
                                .help(file.path)
                                .labelStyle(.titleAndIcon)
                        }
                        .lineSpacing(0)
                        .buttonStyle(mdEditorListButtonStyle())
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }

            }
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            loadRecentFiles()
        }
        .padding([.horizontal, .bottom], 20)
        .frame(width: 700, height: 400)
        .background(color)
        .tint(buttonColor)
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .buttonStyle(mdEditorButtonStyle())
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: markdownTypes) { result in
            Task {
                switch result {
                case .success(let url):
                    do {
                        _ = try await openDocument(at: url)
                        dismiss()
                    } catch {
                        print("Failed to open document:", error.localizedDescription)
                    }
                case .failure(let error):
                    print("File import failed:", error.localizedDescription)
                }
            }
        }
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
    MarkdownWelcomeView()
}
