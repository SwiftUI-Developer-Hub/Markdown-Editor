//
//  Commands.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI

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
    var body: some Commands {
        CommandGroup(replacing: .sidebar) {}
        CommandGroup(replacing: .toolbar) {}
        CommandGroup(replacing: .printItem) {}
        CommandGroup(replacing: .appSettings) {}
        CommandGroup(replacing: .systemServices) {}
        CommandGroup(replacing: .singleWindowList) {}
    }
}
