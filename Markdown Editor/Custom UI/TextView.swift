//
//  SwiftNSView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import AppKit
import SwiftUI

fileprivate struct CursorPosition {
    var start: Int
    var end: Int
}

fileprivate class Global {
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
            let previousSelectedRange = textView.selectedRange()
            textView.string = text

            let clampedLocation = min(previousSelectedRange.location, text.utf16.count)
            let clampedLength = min(previousSelectedRange.length, text.utf16.count - clampedLocation)
            textView.setSelectedRange(NSRange(location: clampedLocation, length: clampedLength))
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
            
            let nsRange = textView.selectedRange()
            let string = textView.string
            
            guard nsRange.location <= string.utf16.count else {
                selection.wrappedValue = nil
                return
            }

            // Convert to Swift String indices safely
            let utf16 = string.utf16
            guard let from = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
                  let to = utf16.index(from, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
                  let lowerBoundIndex = String.Index(from, within: string),
                  let upperBoundIndex = String.Index(to, within: string) else {
                selection.wrappedValue = nil
                return
            }

            selection.wrappedValue = .init(range: lowerBoundIndex..<upperBoundIndex)
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

fileprivate class PlainTextView: NSTextView {
    override func menu(for event: NSEvent) -> NSMenu? {
        return nil
    }

    override func `self`() -> Self {
        self.isEditable = true
        self.allowsUndo = true
        self.usesFindBar = true
        self.isSelectable = true
        self.alignment = .justified
        self.drawsBackground = false
        self.isFieldEditor = false
        self.autoresizesSubviews = true
        self.displaysLinkToolTips = true
        self.isGrammarCheckingEnabled = true
        self.baseWritingDirection = .natural
        self.setSelectedRange(NSMakeRange(0, 0))
        self.autoresizingMask = [.width, .height]
        self.textContainer?.lineFragmentPadding = 4
        self.smartInsertDeleteEnabled = true
        self.isContinuousSpellCheckingEnabled = true
        self.isAutomaticDataDetectionEnabled = false
        self.isAutomaticLinkDetectionEnabled = false
        self.isAutomaticTextCompletionEnabled = true
        self.isAutomaticTextReplacementEnabled = true
        self.isAutomaticDashSubstitutionEnabled = false
        self.isAutomaticQuoteSubstitutionEnabled = false
        self.isAutomaticSpellingCorrectionEnabled = true
        self.textContainer?.lineFragmentPadding = 10
        self.textContainer?.widthTracksTextView = true
        self.textContainer?.lineBreakMode = .byWordWrapping
        self.insertionPointColor = NSColor(
            Color(
                light: Color(rgba: 0x2c65_cfff),
                dark: Color(rgba: 0x4c8e_f8ff)
            )
        )
        self.postsFrameChangedNotifications = true
        self.translatesAutoresizingMaskIntoConstraints = true
        self.textContainerInset = NSSize(width: 8, height: 8)
        self.font = NSFont.systemFont(ofSize: 16)
        self.writingToolsCoordinator = .none
        self.writingToolsBehavior = .limited
        self.allowedWritingToolsResultOptions = [.plainText]
        self.textLayoutManager?.usesFontLeading = true
        self.textLayoutManager?.usesHyphenation = true
        self.textLayoutManager?.limitsLayoutForSuspiciousContents = true
        self.textLayoutManager?.textContentManager?.automaticallySynchronizesToBackingStore = true
        self.textLayoutManager?.textContentManager?.automaticallySynchronizesTextLayoutManagers = true

        // Create a paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.8
        paragraphStyle.alignment = .justified
        paragraphStyle.lineBreakStrategy = .pushOut
        paragraphStyle.usesDefaultHyphenation = true
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.allowsDefaultTighteningForTruncation = true

        // Apply to the text view's typing attributes
        self.defaultParagraphStyle = paragraphStyle
        self.typingAttributes[.paragraphStyle] = paragraphStyle
        return self
    }
}
