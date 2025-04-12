//
//  Markdown_EditorApp.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/9/25.
//
import SwiftUI
import UniformTypeIdentifiers

@main
struct Markdown_EditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var markdownText = ""
    @State private var selection: TextSelection? = nil
    @State private var filepath: URL?

    init() {
    }

    var body: some Scene {
        Window("", id: "") {
            MarkdownEditorView(markdownText: $markdownText, selection: $selection)
                .navigationTitle(filepath?.lastPathComponent ?? "Untitled")
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
                .disabled(((filepath?.lastPathComponent.isEmpty) == nil))
            }
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
            }
        }
    }

    private func saveFile(saveAs: Bool = false) {
        if saveAs || filepath == nil {
            // Always show Save As if `saveAs` is true or the file hasn't been saved yet
            let panel = NSSavePanel()
            panel.allowedContentTypes = [
                UTType(filenameExtension: "md")!,
                UTType(filenameExtension: "mkdn")!
            ]
            panel.nameFieldStringValue = filepath?.lastPathComponent ?? "Untitled.md"  // Default name or current file name

            if panel.runModal() == .OK, let url = panel.url {
                do {
                    try markdownText.write(to: url, atomically: true, encoding: .utf8)
                    filepath = url  // Save the new file path
                } catch {
                    print("Error saving file: \(error.localizedDescription)")
                }
            } else {
                print("Save panel was canceled or failed to get a URL")
            }
        } else {
            // File already has a filepath – save directly without prompting
            do {
                try markdownText.write(to: filepath!, atomically: true, encoding: .utf8)
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillUpdate(_ notification: Notification) {
        hideAutoFill()
    }

    func applicationDidUpdate(_ notification: Notification) {
        hideAutoFill()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        hideAutoFill()
    }

    func hideAutoFill(){
        DispatchQueue.main.async {
            guard let submenu = NSApplication.shared.mainMenu?
                .items.first(where: { $0.title == "Edit" })?
                .submenu else { return }

            if let itemToRemove = submenu.items.first(where: { $0.title == "AutoFill" }) {
                submenu.removeItem(itemToRemove)
            }
        }
    }
}

