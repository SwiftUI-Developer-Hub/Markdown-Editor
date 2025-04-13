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
    var contexts: Context?
    var onDone: (() -> Void)?
    init(text: Binding<String>, selection: Binding<TextSelection?>) {
        _text = text
        _selection = selection
    }
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = PlainTextView.scrollableTextView()

        // MARK: - NSScrollView Settings
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.allowsMagnification = true
        scrollView.allowedTouchTypes = .indirect
        scrollView.autoresizingMask = [.width, .height]
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
        textView.usesFindPanel = true
        textView.drawsBackground = false
        textView.autoresizesSubviews = true
        textView.displaysLinkToolTips = true
        textView.isGrammarCheckingEnabled = true
        textView.baseWritingDirection = .natural
        textView.setSelectedRange(NSMakeRange(0, 0))
        textView.autoresizingMask = [.width, .height]
        textView.textContainer?.lineFragmentPadding = 4
        textView.isContinuousSpellCheckingEnabled = true
        textView.isAutomaticSpellingCorrectionEnabled = true
        textView.textContainer?.lineBreakMode = .byWordWrapping
        textView.insertionPointColor = NSColor(Color.accentColor)
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.textContainerInset = NSSize(width: 4, height: 8)
        textView.font = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular)
        textView.writingToolsCoordinator = .none
        textView.writingToolsBehavior = .limited
        textView.allowedWritingToolsResultOptions = [.plainText]
        // Create a paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.8

        // Apply to the text view's typing attributes
        textView.defaultParagraphStyle = paragraphStyle
        textView.typingAttributes[.paragraphStyle] = paragraphStyle

        if textView.string != text {
            textView.string = text
        }

//         = context.coordinator

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

            let oldText = text.wrappedValue
            let newText = textView.string

            text.wrappedValue = newText

            textView.undoManager?.registerUndo(withTarget: self) { target in
                target.text.wrappedValue = oldText
            }
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

class PlainTextView: NSTextView {
    // You can override the menu method to disable the context menu if you still need it
    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
}
