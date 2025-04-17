//
//  WelecomWindowState.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/16/25.
//

import SwiftUI

enum  WelecomWindowState {
    case active, inactive
}

extension FocusedValues {
    var welecomWindowState: WelecomWindowStateKey.Value? {
        get { self[WelecomWindowStateKey.self] }
        set { self[WelecomWindowStateKey.self] = newValue }
    }
}

struct WelecomWindowStateKey: FocusedValueKey {
    typealias Value = WelecomWindowState
}
