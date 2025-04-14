//
//  AppDelegate.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI

struct WindowCommands: Commands {
    var isWelcome: Bool = false

    init(_ isWelcome: Bool) {
        self.isWelcome = isWelcome
    }

    var body: some Commands {
        CommandGroup(replacing: .sidebar) { }
        CommandGroup(replacing: .toolbar) { }
        CommandGroup(replacing: .printItem) { }
        CommandGroup(replacing: .appSettings) { }
        CommandGroup(replacing: .systemServices) { }
        CommandGroup(replacing: .singleWindowList) { }
        CommandGroup(replacing: .windowArrangement) { }
        if isWelcome {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .saveItem) { }
            CommandGroup(replacing: .textEditing) { }
        } else {
            TextEditingCommands()
        }
    }
}
