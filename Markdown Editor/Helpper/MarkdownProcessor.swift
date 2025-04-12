import Foundation
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
    
    @Binding private var markdownText: String
    private var markdownBlocks: [MarkdownBlock]

    init(markdownText: Binding<String>) {
        _markdownText = markdownText
        self.markdownBlocks = []
    }

    // Apply a markdown type to the selection range
    func applyMarkdownToSelection(
        range: Range<String.Index>?,
        type: MarkdownType
    ) {
        // Determine the current selected range (or the caret position if nil).
        var selectedRange = range ?? markdownText.startIndex..<markdownText.startIndex
        // Get the currently selected text.
        var selectedText = String(markdownText[selectedRange])
        // If nothing is selected, use a descriptive string for the type.
        selectedText = selectedRange.isEmpty && selectedText.isEmpty ? type.description() : selectedText

        // Format based on markdown type.
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

        // Update the markdown text and advance the selection (cursor) to the end of the inserted text.
        if markdownText.isEmpty {
            markdownText = formattedText
            selectedRange = markdownText.endIndex..<markdownText.endIndex
        } else if selectedRange.isEmpty {
            markdownText.insert(contentsOf: formattedText, at: selectedRange.lowerBound)
            if let newPosition = markdownText.index(selectedRange.lowerBound, offsetBy: formattedText.count, limitedBy: markdownText.endIndex) {
                selectedRange = newPosition..<newPosition
            }
        } else {
            let insertionStart = selectedRange.lowerBound
            markdownText.replaceSubrange(selectedRange, with: formattedText)
            if let newPosition = markdownText.index(insertionStart, offsetBy: formattedText.count, limitedBy: markdownText.endIndex) {
                selectedRange = newPosition..<newPosition
            }
        }
    }

    // Function to get the current markdown text after processing
    func getProcessedMarkdown() -> String {
        return markdownText
    }

    // Reset all the markdown blocks (useful for clearing selections or resetting)
    func resetMarkdownBlocks() {
        markdownBlocks.removeAll()
    }

    // Apply a whole range of markdown formatting (can be used for entire document or specific parts)
    func applyMarkdownToFullText(type: MarkdownType) {
        let range = markdownText.startIndex..<markdownText.endIndex
        applyMarkdownToSelection(range: range, type: type)
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
