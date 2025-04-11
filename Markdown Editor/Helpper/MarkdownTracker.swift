//
//  MarkdownTracker.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import SwiftUI

struct MarkdownChange {
    let range: Range<String.Index>
    let originalText: String
    let newText: String

    func apply(to text: inout String) {
        text.replaceSubrange(range, with: newText)
    }

    func undo(to text: inout String) {
        text.replaceSubrange(range, with: originalText)
    }
}

final class MarkdownTracker {
    private var undoStack: [MarkdownChange] = []
    private var redoStack: [MarkdownChange] = []
    var onTextUpdate: ((String) -> Void)?

    private(set) var currentText: String

    init(initialText: String) {
        self.currentText = initialText
    }

    func apply(change: MarkdownChange) {
        change.apply(to: &currentText)
        undoStack.append(change)
        redoStack.removeAll()
        onTextUpdate?(currentText)
    }

    func undo() {
        guard let last = undoStack.popLast() else { return }
        last.undo(to: &currentText)
        redoStack.append(last)
        onTextUpdate?(currentText)
    }

    func redo() {
        guard let last = redoStack.popLast() else { return }
        last.apply(to: &currentText)
        undoStack.append(last)
        onTextUpdate?(currentText)
    }
}
