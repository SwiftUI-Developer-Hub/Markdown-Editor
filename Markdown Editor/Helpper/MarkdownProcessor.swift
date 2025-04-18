//
//  MarkdownProcessor.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import SwiftUI
import Foundation

// Enum to represent different types of markdown
enum MarkdownType {
    case bold
    case italic
    case strikethrough
    case header(level: Int)
    case listItem
    case numberedItem
    case checklist
    case blockquote
    case code
    case table(top: String, middle: String, bottom: String)
    case link(linkName: String, url: String)
    case image(imageName: String, url: String)
}

// Struct to represent a block of markdown
struct MarkdownBlock {
    var range: Range<String.Index> // The range where the markdown applies in the text
    var type: MarkdownType // The type of markdown (bold, link, table, etc.)
}

// The core logic to process and apply markdown formatting
class MarkdownProcessor {
    var undoManager: UndoManager?
    @Binding var markdownText: String
    private var markdownBlocks: [MarkdownBlock]

    init(_ markdownText: Binding<String>, undoManager: UndoManager?) {
        self.markdownBlocks = []
        _markdownText = markdownText
        self.undoManager = undoManager
    }

    func applyMarkdownToSelection(
        _ range: Range<String.Index>?,
        type: MarkdownType,
    ) {
        let selectedRange = range ?? markdownText.startIndex..<markdownText.startIndex
        var selectedText = String(markdownText[selectedRange])
        selectedText = selectedRange.isEmpty && selectedText.isEmpty ? type.description() : selectedText

        let formattedText: String
        switch type {
        case .bold:
            formattedText = "**\(selectedText)**"
        case .italic:
            formattedText = "*\(selectedText)*"
        case .strikethrough:
            formattedText = "~~\(selectedText)~~"
        case .header(let level):
            formattedText = String(repeating: "#", count: level) + " " + selectedText
        case .listItem:
            formattedText = "- \(selectedText)"
        case .numberedItem:
            formattedText = "1. \(selectedText)"
        case .checklist:
            formattedText = "- [ ] \(selectedText)"
        case .blockquote:
            formattedText = "> \(selectedText)"
        case .code:
            formattedText = "```\n\(selectedText)\n```"
        case .table(let top, let middle, let bottom):
            formattedText = "\(top)\n\(middle)\n\(bottom)"
        case .link(let linkName, let url):
            formattedText = "[\(linkName)](\(url))"
        case .image(let imageName, let url):
            formattedText = "![\(imageName)](\(url))"
        }

        let previousText = markdownText

        if markdownText.isEmpty {
            markdownText = formattedText
        } else if selectedRange.isEmpty {
            markdownText.insert(contentsOf: formattedText, at: selectedRange.lowerBound)
        } else {
            markdownText.replaceSubrange(selectedRange, with: formattedText)
        }

        undoManager?.registerUndo(withTarget: self) { target in
            target.markdownText = previousText
        }
    }

    func removeMarkdownAtSelection(
        _ range: Range<String.Index>?,
        type: MarkdownType,
    ) {
        let selectedRange = range ?? markdownText.startIndex..<markdownText.startIndex
        var selectedText = String(markdownText[selectedRange])
        selectedText = selectedRange.isEmpty && selectedText.isEmpty ? type.description() : selectedText

        let formattedText: String
        switch type {
        case .bold:
            formattedText = "**\(selectedText)**"
        case .italic:
            formattedText = "*\(selectedText)*"
        case .strikethrough:
            formattedText = "~~\(selectedText)~~"
        case .header(let level):
            formattedText = String(repeating: "#", count: level) + " " + selectedText
        case .listItem:
            formattedText = "- \(selectedText)"
        case .numberedItem:
            formattedText = "1. \(selectedText)"
        case .checklist:
            formattedText = "- [ ] \(selectedText)"
        case .blockquote:
            formattedText = "> \(selectedText)"
        case .code:
            formattedText = "```\n\(selectedText)\n```"
        case .table(let top, let middle, let bottom):
            formattedText = "\(top)\n\(middle)\n\(bottom)"
        case .link(let linkName, let url):
            formattedText = "[\(linkName)](\(url))"
        case .image(let imageName, let url):
            formattedText = "![\(imageName)](\(url))"
        }

        let previousText = markdownText

        if markdownText.isEmpty {
            markdownText = formattedText
        } else if selectedRange.isEmpty {
            markdownText.insert(contentsOf: formattedText, at: selectedRange.lowerBound)
        } else {
            markdownText.replaceSubrange(selectedRange, with: formattedText)
        }

        undoManager?.registerUndo(withTarget: self) { target in
            target.markdownText = previousText
        }
    }

    func isMarkdownAppliedToSelection(
        _ range: Range<String.Index>?,
        type: MarkdownType
    ) -> Bool {
        let selectedRange = range ?? markdownText.startIndex..<markdownText.startIndex
        let selectedText = String(markdownText[selectedRange])
        
        // Empty selection (insertion point): expand around it
        if selectedRange.isEmpty {
            let position = selectedRange.lowerBound
            
            switch type {
            case .bold:
                return surroundingMatch(start: "**", end: "**", at: position)
            case .italic:
                return surroundingMatch(start: "*", end: "*", at: position)
            case .strikethrough:
                return surroundingMatch(start: "~~", end: "~~", at: position)
            case .code:
                return surroundingMatch(start: "```\n", end: "\n```", at: position)
            case .blockquote:
                return lineHasPrefix("> ", at: position)
            case .listItem:
                return lineHasPrefix("- ", at: position)
            case .numberedItem:
                return lineHasPrefix("1. ", at: position)
            case .checklist:
                return lineHasPrefix("- [ ] ", at: position)
            case .header(let level):
                return lineHasPrefix(String(repeating: "#", count: level) + " ", at: position)
            default:
                return false
            }
        }

        // With selection: check the selected text
        switch type {
        case .bold:
            return selectedText.hasPrefix("**") && selectedText.hasSuffix("**")
        case .italic:
            return selectedText.hasPrefix("*") && selectedText.hasSuffix("*")
        case .strikethrough:
            return selectedText.hasPrefix("~~") && selectedText.hasSuffix("~~")
        case .header(let level):
            let prefix = String(repeating: "#", count: level) + " "
            return selectedText.hasPrefix(prefix)
        case .listItem:
            return selectedText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("- ")
        case .numberedItem:
            return selectedText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("1. ")
        case .checklist:
            return selectedText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("- [ ] ")
        case .blockquote:
            return selectedText.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("> ")
        case .code:
            return selectedText.hasPrefix("```\n") && selectedText.hasSuffix("\n```")
        case .table(let top, let middle, let bottom):
            let formattedTable = "\(top)\n\(middle)\n\(bottom)"
            return selectedText == formattedTable
        case .link(let linkName, let url):
            return selectedText == "[\(linkName)](\(url))"
        case .image(let imageName, let url):
            return selectedText == "![\(imageName)](\(url))"
        }
    }
    
    func clearAllMarkdown() {
        let previousText = markdownText

        var newText = markdownText

        // Remove inline styles: bold, italic, strikethrough
        newText = newText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        newText = newText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        newText = newText.replacingOccurrences(of: "~~(.*?)~~", with: "$1", options: .regularExpression)

        // Headers: remove leading # symbols
        newText = newText.replacingOccurrences(of: "^#{1,6}\\s*", with: "", options: [.regularExpression, .anchored, .caseInsensitive])

        // Lists: remove bullet characters, numbers, checkboxes
        newText = newText.replacingOccurrences(of: "^- \\[ \\] ", with: "", options: [.regularExpression, .anchored])
        newText = newText.replacingOccurrences(of: "^\\d+\\.\\s+", with: "", options: [.regularExpression, .anchored])
        newText = newText.replacingOccurrences(of: "^-\\s+", with: "", options: [.regularExpression, .anchored])

        // Blockquote: remove `>` character
        newText = newText.replacingOccurrences(of: "^>\\s+", with: "", options: [.regularExpression, .anchored])

        // Code block: remove triple backticks and keep content
        newText = newText.replacingOccurrences(of: "```(?:\\n)?([\\s\\S]*?)(?:\\n)?```", with: "$1", options: .regularExpression)

        // Inline image: alt text + url
        newText = newText.replacingOccurrences(
            of: "!\\[(.*?)\\]\\((.*?)\\)",
            with: "$2",
            options: .regularExpression
        )

        // Inline link: text + url
        newText = newText.replacingOccurrences(
            of: "\\[(.*?)\\]\\((.*?)\\)",
            with: "$2",
            options: .regularExpression
        )

        // Table rows: just strip the pipes
        newText = newText.replacingOccurrences(of: "\\|", with: "", options: .regularExpression)

        // Horizontal rules: delete them completely
        newText = newText.replacingOccurrences(of: "\\n-{3,}\\n", with: "\n", options: .regularExpression)

        markdownText = newText

        undoManager?.registerUndo(withTarget: self) { target in
            target.markdownText = previousText
        }
    }

    private func surroundingMatch(start: String, end: String, at position: String.Index) -> Bool {
        let text = markdownText
        guard let startRange = text.range(of: start, options: .backwards, range: text.startIndex..<position),
              let endRange = text.range(of: end, options: [], range: position..<text.endIndex)
        else {
            return false
        }
        // Ensure markers are balanced and there's content between them
        let inner = text[startRange.upperBound..<endRange.lowerBound]
        return !inner.isEmpty
    }

    private func lineHasPrefix(_ prefix: String, at position: String.Index) -> Bool {
        let text = markdownText
        let lineStart = text[..<position].lastIndex(of: "\n").map { text.index(after: $0) } ?? text.startIndex
        let lineEnd = text[position...].firstIndex(of: "\n") ?? text.endIndex
        let line = text[lineStart..<lineEnd]
        return line.hasPrefix(prefix)
    }
}

extension MarkdownType {
    func description() -> String {
        switch self {
        case .bold:
            return "Bold"
        case .italic:
            return "Italic"
        case .strikethrough:
            return "Strikethrough"
        case .header(let level):
            return "Header \(level)"
        case .listItem:
            return "List Item"
        case .numberedItem:
            return "Numbered Item"
        case .checklist:
            return "Checklist"
        case .blockquote:
            return "Blockquote"
        case .code:
            return "Code Block"
        case .table:
            return "Table"
        case .link(_, let url):
            return "Link to \(url)"
        case .image(_, let url):
            return "Image from \(url)"
        }
    }
}
