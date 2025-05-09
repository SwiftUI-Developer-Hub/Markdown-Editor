//
//  MarkdownProcessor.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import SwiftUI

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

    func applyMarkdownToSelection(_ range: Range<String.Index>?, type: MarkdownType) {
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

    func clearAllMarkdownForSelection(_ range: Range<String.Index>?) {
        let selectedRange = range ?? markdownText.startIndex..<markdownText.startIndex
        var selectedText = String(markdownText[selectedRange])
        selectedText = selectedRange.isEmpty && selectedText.isEmpty ? markdownText : selectedText

        let previousText = markdownText

        // Remove inline styles: bold, italic, strikethrough
        selectedText = selectedText.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
        selectedText = selectedText.replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
        selectedText = selectedText.replacingOccurrences(of: "~~(.*?)~~", with: "$1", options: .regularExpression)

        // Headers: remove leading # symbols (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "(?m)^#{1,6}\\s*", with: "", options: .regularExpression)

        // Lists: remove checkboxes, bullets, and numbered prefixes (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "(?m)^- \\[\\s\\] ", with: "", options: .regularExpression)
        selectedText = selectedText.replacingOccurrences(of: "(?m)^\\d+\\.\\s+", with: "", options: .regularExpression)
        selectedText = selectedText.replacingOccurrences(of: "(?m)^[-*+]\\s+", with: "", options: .regularExpression)

        // Blockquotes: allow multiline blockquotes (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "(?m)^>\\s+", with: "", options: .regularExpression)

        // Code blocks: remove code block formatting (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "```(?:\\n)?([\\s\\S]*?)(?:\\n)?```", with: "$1", options: .regularExpression)

        // Inline images: remove image syntax (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "!\\[(.*?)\\]\\((.*?)\\)", with: "$2", options: .regularExpression)

        // Inline links: remove link syntax (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "\\[(.*?)\\]\\((.*?)\\)", with: "$2", options: .regularExpression)

        // Tables: remove pipe symbols (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "(?m)\\|", with: "", options: .regularExpression)

        // Horizontal rules: remove horizontal rules (support multiline with (?m))
        selectedText = selectedText.replacingOccurrences(of: "(?m)^(\\s*)([-*_]){3,}\\s*$", with: "", options: .regularExpression)

        // Replace only selected range or the entire text
        if selectedRange != markdownText.startIndex..<markdownText.startIndex {
            markdownText.replaceSubrange(selectedRange, with: selectedText)
            undoManager?.registerUndo(withTarget: self) { target in
                target.markdownText = previousText
            }
        }
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
