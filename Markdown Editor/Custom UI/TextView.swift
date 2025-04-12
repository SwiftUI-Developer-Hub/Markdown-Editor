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

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()

        // MARK: - NSScrollView Settings
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.autoresizingMask = .width
        scrollView.allowsMagnification = true
        scrollView.allowedTouchTypes = .indirect
        scrollView.horizontalScrollElasticity = .automatic
        scrollView.automaticallyAdjustsContentInsets = true
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.contentInsets = .init(top: 16, left: 8, bottom: 16, right: 8)
        
        // MARK: - NStextView Settings
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.displaysLinkToolTips = true
        textView.autoresizesSubviews = true
        textView.autoresizingMask = .width
        textView.smartInsertDeleteEnabled = true
        textView.isGrammarCheckingEnabled = true
        textView.baseWritingDirection = .natural
        textView.setSelectedRange(NSMakeRange(0, 0))
        textView.isContinuousSpellCheckingEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.isAutomaticDashSubstitutionEnabled = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.textContainer?.lineFragmentPadding = 4
        textView.textContainer?.lineBreakMode = .byWordWrapping
        textView.textContainerInset = NSSize(width: 4, height: 8)
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.insertionPointColor = NSColor(Color.accentColor)
        textView.font = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular)

        // Customize the menu
        textView.menu = cleanContextMenu(from: textView.menu)

        if textView.string != text {
            textView.string = text
        }

        // Return the scroll view
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        // Sync the text value if it has changed
        if textView.string != text {
            textView.string = text
        }

        DispatchQueue.main.async {
            if textView.window?.firstResponder !== textView {
                textView.window?.makeFirstResponder(textView)
            }
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


func cleanContextMenu(from menu: NSMenu?) -> NSMenu {
    guard let menu = menu else { return NSMenu() }

    let keepTitles: Set<String> = [
        "Cut", "Copy", "Paste",
        "Spelling and Grammar", "Speech"
    ]

    let newMenu = NSMenu(title: "Cleaned Menu")

    for item in menu.items {
        let title = item.title.components(separatedBy: CharacterSet.newlines).first ?? item.title

        if keepTitles.contains(title) {
            let copiedItem = item.copy() as! NSMenuItem
            newMenu.addItem(copiedItem)
        }
    }

    return newMenu
}
