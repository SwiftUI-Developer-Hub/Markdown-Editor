//
//  SwiftNSView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import AppKit
import SwiftUI
import Combine
import Foundation

struct CursorPosition {
    var start: Int
    var end: Int
}

class Global {
    public static var cursorPosition = CursorPosition(start: 0, end: 0)
}

struct TextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var selection: TextSelection?
    var onDone: (() -> Void)?

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        // Sync the text value if it has changed
        if nsView.string != text {
            nsView.string = text
        }

        // Ensure the text view is the first responder if not already
        if nsView.window?.firstResponder !== nsView {
            nsView.window?.makeFirstResponder(nsView)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, selection: $selection, onDone: onDone)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var selection: Binding<TextSelection?>
        var onDone: (() -> Void)?

        init(text: Binding<String>, selection: Binding<TextSelection?>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.selection = selection
            self.onDone = onDone
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }

        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            if let onDone = onDone, replacementString == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Get the selected range as NSRange
            let selectedRange = textView.selectedRange()

            // Convert the selected range from NSRange to Range<String.Index>
            let lowerBoundIndex = textView.string.index(textView.string.startIndex, offsetBy: selectedRange.location)
            let upperBoundIndex = textView.string.index(lowerBoundIndex, offsetBy: selectedRange.length)

            // Create the Range<String.Index> and update the selection
            selection.wrappedValue = TextSelection(range: lowerBoundIndex..<upperBoundIndex)
        }
    }
}

extension StringProtocol {
    func nsRange(from range: Range<Index>) -> NSRange {
        let string = String(self)
        return NSRange(range, in: string)
    }

    func range(from nsRange: NSRange) -> Range<Index>? {
        let string = String(self)
        guard let from16 = string.utf16.index(string.utf16.startIndex, offsetBy: nsRange.location, limitedBy: string.utf16.endIndex),
              let to16 = string.utf16.index(from16, offsetBy: nsRange.length, limitedBy: string.utf16.endIndex),
              let start = Index(from16, within: string),
              let end = Index(to16, within: string) else {
            return nil
        }
        return start..<end
    }
}

