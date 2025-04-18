//
//  AppDelegate.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let unwantedTitles = ["Substitutions", "AutoFill", "Writing Tools"]

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let editMenu = NSApp.mainMenu?.item(withTitle: "Edit")?.submenu else {
            print("Menu items not found")
            return
        }
        editMenu.delegate = self
        if isDebug() {
            print("Menu items found:")
            var seenTitles = Set<String>()
            
            for item in editMenu.items {
                guard seenTitles.insert(item.title).inserted else { continue }
                print("• \(item.title)")
                
                if let submenu = item.submenu {
                    for subItem in submenu.items {
                        guard seenTitles.insert(subItem.title).inserted else { continue }
                        print("   ◦ \(subItem.title)")
                    }
                }
            }
        }
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationWillUpdate(_ notification: Notification) {
        guard let editMenu = NSApp.mainMenu?.item(withTitle: "Edit")?.submenu else {
            print("Menu items not found")
            return
        }

        editMenu.delegate = self

        // Remove unwanted top-level items
        for item in editMenu.items.reversed() {
            if unwantedTitles.contains(item.title) {
                editMenu.removeItem(item)
                continue
            }
        }
    }

    // This is called every time right before the menu opens
    func menuNeedsUpdate(_ menu: NSMenu) {

        guard menu.title == "Edit" else {
            print("Menu items not found")
            return
        }

        // Remove unwanted top-level items
        for item in menu.items {
            if unwantedTitles.contains(item.title) {
                menu.removeItem(item)
                continue
            }
        }
    }

}
