//
//  AppDelegate.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Grab the Edit submenu and set self as its delegate
        if let editMenu = NSApp.mainMenu?
            .item(withTitle: "Edit")?
            .submenu {
            editMenu.delegate = self
        }
    }

    // This is called every time right before the menu opens
    func menuNeedsUpdate(_ menu: NSMenu) {
        // Only prune the Edit menu
        guard menu.title == "Edit" else { return }

        let unwanted = ["AutoFill", "Substitutions"]
        unwanted.forEach { title in
            if let item = menu.item(withTitle: title) {
                menu.removeItem(item)
            }
        }
    }
}
