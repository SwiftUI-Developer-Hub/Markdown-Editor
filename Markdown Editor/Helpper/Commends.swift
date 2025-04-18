//
//  Commands.swift
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
