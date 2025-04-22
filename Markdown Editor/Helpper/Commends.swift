//
//  Commands.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: Editor View Menu Commands
struct EditorCommands: Commands {
    var body: some Commands {
        BaseCommands()
        TextEditingCommands()
    }
}

// MARK: Welcome View Menu Commands
struct WelcomeCommands: Commands {

    var body: some Commands {
        BaseCommands()
        CommandGroup(replacing: .saveItem) {}
        CommandGroup(replacing: .undoRedo) {}
        CommandGroup(replacing: .windowList) {}
        CommandGroup(replacing: .windowSize) {}
        CommandGroup(replacing: .pasteboard) {}
        CommandGroup(replacing: .textEditing) {}
        CommandGroup(replacing: .importExport) {}
        CommandGroup(replacing: .windowArrangement) {}
    }
}

// MARK: Base Menu Commands
fileprivate struct BaseCommands: Commands {
    @State var showFileImporter: Bool = false
    private var markdownTypes: [UTType] = [
        .md, .mkd, .mkdn, .mdwn, .mdown, .mdtxt, .mdtext, .markdown, .plainText
    ]
    @Environment(\.newDocument) private var newDocument
    @Environment(\.openDocument) private var openDocument
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some Commands {
        CommandGroup(replacing: .sidebar) {}
        CommandGroup(replacing: .toolbar) {}
        CommandGroup(replacing: .printItem) {}
        CommandGroup(replacing: .appSettings) {}
        CommandGroup(replacing: .newItem) {
            Button("New") {
                newDocument(MarkdownFile())
            }
            .keyboardShortcut("n", modifiers: [.command])
            Button("Open") {
                showFileImporter = true
                dismissWindow(id: "markdownWelcomeWindow")
            }
            .keyboardShortcut("o", modifiers: [.command])
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: markdownTypes) { result in
                Task {
                    switch result {
                    case .success(let url):
                        do {
                            _ = try await openDocument(at: url)
                        } catch {
                            print("Failed to open document:", error.localizedDescription)
                        }
                    case .failure(let error):
                        print("File import failed:", error.localizedDescription)
                    }
                }
            }
        }
        CommandGroup(replacing: .systemServices) {}
        CommandGroup(replacing: .singleWindowList) {}
    }
}
