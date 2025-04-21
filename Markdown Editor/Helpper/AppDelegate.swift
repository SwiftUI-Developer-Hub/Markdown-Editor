//
//  AppDelegate.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let unwantedTitles = ["Substitutions", "AutoFill", "Writing Tools"]

    // MARK: Only Works On All Window Types, But Not All Item's
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

    // MARK: Only Works On Document Groups
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

    // MARK: Only Works On Window & Window Group
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
