//
//  Markdown_EditorApp.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/9/25.
//
import Cocoa
import SwiftUI
import UniformTypeIdentifiers

@main
struct Markdown_EditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var markdownText = ""
    @State private var selection: TextSelection? = nil
    @State private var filepath: URL?

    var body: some Scene {
        Window("", id: "") {
            MarkdownEditorView(markdownText: $markdownText, selection: $selection)
                .navigationTitle(filepath?.lastPathComponent ?? "Untitled")
                .onChange(of: filepath) { _, _ in
                    updateWindowTitle()
                }
                .windowDismissBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .sidebar) { }
            CommandGroup(replacing: .toolbar) { }
            CommandGroup(replacing: .printItem) { }
            CommandGroup(replacing: .appSettings) { }
            CommandGroup(replacing: .systemServices) { }
            CommandGroup(replacing: .singleWindowList) { }
            CommandGroup(replacing: .windowArrangement) { }
            CommandGroup(after: .saveItem) {
                Button("Open...") {
                    openFile()
                }
                .keyboardShortcut("o", modifiers: .command)

                Button("Save") {
                    saveFile(saveAs: false)
                }
                .keyboardShortcut("s", modifiers: .command)

                Button("Save As...") {
                    saveFile(saveAs: true)
                }
                .keyboardShortcut("S", modifiers: [.command, .shift])
            }
            TextEditingCommands()
        }
        .windowLevel(.normal)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.expanded)
        .windowIdealSize(.fitToContent)
        .windowManagerRole(.associated)
        .windowResizability(.contentSize)
        .windowToolbarLabelStyle(fixed: .iconOnly)
    }

    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType(filenameExtension: "md")!,
            UTType(filenameExtension: "mkdn")!
        ]
        if panel.runModal() == .OK, let url = panel.url {
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                markdownText = content
                filepath = url
                updateWindowTitle()
            }
        }
    }

    private func saveFile(saveAs: Bool = false) {
        if saveAs || filepath == nil {
            let panel = NSSavePanel()
            panel.allowedContentTypes = [
                UTType(filenameExtension: "md")!,
                UTType(filenameExtension: "mkdn")!
            ]
            panel.nameFieldStringValue = filepath?.lastPathComponent ?? "Untitled.md"

            if panel.runModal() == .OK, let url = panel.url {
                do {
                    try markdownText.write(to: url, atomically: true, encoding: .utf8)
                    filepath = url
                    updateWindowTitle()
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                }
            }
        } else {
            do {
                try markdownText.write(to: filepath!, atomically: true, encoding: .utf8)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }
    }

    private func updateWindowTitle() {
        NSApp.keyWindow?.title = filepath?.lastPathComponent ?? "Untitled"
    }
}
