//
//  SwiftNSView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import AppKit
import SwiftUI
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
    @Binding var isScrolling: Bool
    @Binding var scrollPosition: CGPoint?
    @Binding var selection: TextSelection?
    var currentScrollPosition: ((_ position: CGPoint) -> Void)?
    private var onDone: (() -> Void)?

    init(text: Binding<String>, isScrolling: Binding<Bool>, selection: Binding<TextSelection?>, scrollPosition: Binding<CGPoint?>, currentScrollPosition: ((_ position: CGPoint) -> Void)?) {
        _text = text
        _selection = selection
        _isScrolling = isScrolling
        _scrollPosition = scrollPosition
        self.currentScrollPosition = currentScrollPosition
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = PlainTextView.scrollableTextView()

        // MARK: - NSScrollView Settings
        scrollView.focusRingType = .none
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.autohidesScrollers = true
        scrollView.autoresizesSubviews = true
        scrollView.allowsMagnification = false
        scrollView.verticalScrollElasticity = .allowed
        scrollView.autoresizingMask = [.width, .height]
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.contentView.postsBoundsChangedNotifications = true

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
        textView.alignment = .justified
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
        textView.textContainer?.lineBreakMode = .byCharWrapping
        textView.insertionPointColor = NSColor(Color.accentColor)
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.font = NSFont.systemFont(ofSize: 16)
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

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.contentViewDidChangeBounds(_:)),
            name: NSScrollView.didLiveScrollNotification,
            object: scrollView
        )

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.contentViewDidEndBounds(_:)),
            name: NSScrollView.didEndLiveScrollNotification,
            object: scrollView
        )

        // Return the scroll view
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        // Sync the text value if it has changed
        if textView.string != text {
            textView.string = text
        }
        
        DispatchQueue.main.async {
            if textView.window?.firstResponder !== textView {
                textView.window?.makeFirstResponder(textView)
            }
        }

        // Scroll to a point if provided
        if isScrolling {
            if let scrollPosition = scrollPosition {
                scrollView.contentView.scroll(scrollPosition)
                scrollView.reflectScrolledClipView(scrollView.contentView)
                DispatchQueue.main.async {
                    self.scrollPosition = nil
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, selection: $selection, isScrolling: .constant(isScrolling), currentScrollPosition: currentScrollPosition, onDone: onDone)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var isScrolling: Binding<Bool>
        var selection: Binding<TextSelection?>
        var currentScrollPosition: ((_ position: CGPoint) -> Void)?
        var onDone: (() -> Void)?

        init(text: Binding<String>, selection: Binding<TextSelection?>, isScrolling: Binding<Bool>, currentScrollPosition: ((_ position: CGPoint) -> Void)?, onDone: (() -> Void)? = nil) {
            self.text = text
            self.onDone = onDone
            self.selection = selection
            self.isScrolling = isScrolling
            self.currentScrollPosition = currentScrollPosition
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

        @objc func contentViewDidChangeBounds(_ notification: Notification) {
            guard let scrollView = notification.object as? NSScrollView else { return }
            // TODO: Synced scroll mostly works, but there's a minor mismatch in bottom offset when scrolling NSScrollView -> SwiftUI.
            // Probably due to layout/coordinate differences. Leaving this for future cleanup (or a brave soul).
            DispatchQueue.main.async {
                self.isScrolling.wrappedValue = false
                self.currentScrollPosition?(scrollView.documentVisibleRect.origin)
            }
        }

        @objc func contentViewDidEndBounds(_ notification: Notification) {
            DispatchQueue.main.async {
                self.isScrolling.wrappedValue = true
            }
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

class PlainTextView: NSTextView {
    // You can override the menu method to disable the context menu if you still need it
    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }
}
