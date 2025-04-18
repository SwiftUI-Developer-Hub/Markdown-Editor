//
//  Extensions.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

extension View {
    func basicEditMenu() -> some View {
        self.contextMenu {
            // Core editing actions
            Button("Cut") {
                NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
            }
            .help("Cut the selected text")

            Button("Copy") {
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
            }
            .help("Copy the selected text")

            Button("Paste") {
                NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
            }
            .help("Paste text from the clipboard")

            Divider()

            Button("Select All") {
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
            }
            .help("Select all the text")

            Divider()

            SpellingAndGrammarMenu()
        }
    }
}

extension UTType {
    static var md: UTType {
        UTType(filenameExtension: "md")!
    }

    static var mkdn: UTType {
        UTType(filenameExtension: "mkdn")!
    }
}
