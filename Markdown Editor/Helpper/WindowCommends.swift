//
//  AppDelegate.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI

struct WindowCommands: Commands {
    var body: some Commands {
        TextEditingCommands()
        CommandGroup(replacing: .sidebar) { }
        CommandGroup(replacing: .toolbar) { }
        CommandGroup(replacing: .newItem) { }
        CommandGroup(replacing: .printItem) { }
        CommandGroup(replacing: .appSettings) { }
        CommandGroup(replacing: .systemServices) { }
        CommandGroup(replacing: .singleWindowList) { }
        CommandGroup(replacing: .windowArrangement) { }
    }
}
