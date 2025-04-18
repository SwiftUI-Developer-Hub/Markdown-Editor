//
//  AppDelegate.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI

struct EditorCommands: Commands {
    var body: some Commands {
        BaseCommands()
        TextEditingCommands()
    }
}

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

fileprivate struct BaseCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .sidebar) {}
        CommandGroup(replacing: .toolbar) {}
        CommandGroup(replacing: .printItem) {}
        CommandGroup(replacing: .appSettings) {}
        CommandGroup(replacing: .systemServices) {}
        CommandGroup(replacing: .singleWindowList) {}
    }
}

struct SpellingAndGrammarMenu: View {
    var body: some View {
        Menu("Spelling and Grammar") {
            Button("Show Spelling and Grammar") {
                toggleSetting(selector: #selector(NSTextView.showGuessPanel(_:)))
            }
            .keyboardShortcut(":", modifiers: .command)
            .help("Open the spelling and grammar panel.")

            Button("Check Document Now") {
                toggleSetting(selector: #selector(NSTextView.checkSpelling(_:)))
            }
            .keyboardShortcut(";", modifiers: .command)
            .help("Run a manual spell check on the current document.")

            Divider()

            Button("Check Spelling While Typing") {
                toggleSetting(selector: #selector(NSTextView.toggleContinuousSpellChecking(_:)))
            }
            .help("Toggle real-time spell checking as you type.")

            Button("Check Grammar With Spelling") {
                toggleSetting(selector: #selector(NSTextView.toggleGrammarChecking(_:)))
            }
            .help("Enable grammar checking along with spelling.")

            Button("Correct Spelling Automatically") {
                toggleSetting(selector: #selector(NSTextView.toggleAutomaticSpellingCorrection(_:)))
            }
            .help("Automatically fix spelling errors as you type.")
        }
    }
}

