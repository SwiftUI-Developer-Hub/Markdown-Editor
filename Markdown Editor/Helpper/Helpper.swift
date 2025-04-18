//
//  Extensions.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

func isDebug() -> Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

func toggleSetting(selector: Selector) {
    NSApp.sendAction(selector, to: nil, from: nil)
}
