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
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    // This is called every time right before the menu opens
    func menuNeedsUpdate(_ menu: NSMenu) {

        guard menu.title == "Edit" else { return }

        let unwantedTitles = ["Substitutions", "Transformations", "AutoFill"]

        for item in menu.items {
            if unwantedTitles.contains(item.title) {
                menu.removeItem(item)
            }

            // Also check submenu titles (e.g., Substitutions, Transformations)
            if let submenu = item.submenu {
                submenu.items.forEach { subItem in
                    if unwantedTitles.contains(subItem.title) {
                        submenu.removeItem(subItem)
                    }
                }
            }
        }
    }

}
