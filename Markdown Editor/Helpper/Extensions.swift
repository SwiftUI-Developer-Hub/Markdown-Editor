//
//  Extensions.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: Basic Edit Menu
extension View {
    func basicEditMenu(_ text: Binding<String>, selectedRange: Range<String.Index>?) -> some View {
        self.contextMenu {
            // Only show spell checking options if there's a selected range
            if let range = selectedRange, !range.isEmpty {
                // Convert selected range to UTF16 offset
                let utf16Offset = range.lowerBound.utf16Offset(in: text.wrappedValue)

                // Check for misspelled word
                if let misspelled = misspelledWord(at: utf16Offset, in: text.wrappedValue) {
                    let suggestions = suggestions(for: misspelled.word)

                    if !suggestions.isEmpty {
                        // Show suggestions for misspelled word
                        ForEach(suggestions, id: \.self) { guess in
                            Button(guess) {
                                let nsText = text.wrappedValue as NSString
                                let replaced = nsText.replacingCharacters(in: misspelled.range, with: guess)
                                text.wrappedValue = replaced
                            }
                        }
                        Divider()

                        // Button to ignore the word
                        Button("Ignore Spelling") {
                            NSSpellChecker.shared.ignoreWord(misspelled.word, inSpellDocumentWithTag: 0)
                        }
                        .help("Ignore this word in the current document")

                        // Button to learn the word
                        Button("Learn Spelling") {
                            NSSpellChecker.shared.learnWord(misspelled.word)
                        }
                        .help("Add this word to your custom dictionary")

                        Divider()
                    }
                }
            }

            // Core editing actions (cut, copy, paste)
            Button("Cut") {
                NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: nil)
            }
            .help("Cut the selected text")

            Button("Copy") {
                NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: nil)
            }
            .help("Copy the selected text")

            Button("Paste") {
                NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: nil)
            }
            .help("Paste text from the clipboard")

            Divider()

            // Select All action
            Button("Select All") {
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
            }
            .help("Select all the text")

            Divider()

            if let range = selectedRange, !range.isEmpty {
                let stringValue = text.wrappedValue

                if range.lowerBound < stringValue.endIndex && range.upperBound <= stringValue.endIndex {
                    let selectedWord = String(stringValue[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let query = selectedWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

                    Button("Search with Google") {
                        if let url = URL(string: "https://www.google.com/search?q=\(query)") {
                            NSWorkspace.shared.open(url)
                        }
                    }

                    Button("Look Up “\(selectedWord)”") {
                        if let url = URL(string: "dict://\(query)") {
                            NSWorkspace.shared.open(url)
                        }
                    }

                    Divider()
                }
            }

            // Call to the SpellingAndGrammarMenu (if needed)
            SpellingAndGrammarMenu()
        }
    }
}

// MARK: Markdown UTType
extension UTType {
    static var md: UTType { UTType(filenameExtension: "md")! }
    static var mkd: UTType { UTType(filenameExtension: "mkd")! }
    static var mkdn: UTType { UTType(filenameExtension: "mkdn")! }
    static var mdwn: UTType { UTType(filenameExtension: "mdwn")! }
    static var mdown: UTType { UTType(filenameExtension: "mdown")! }
    static var mdtxt: UTType { UTType(filenameExtension: "mdtxt")! }
    static var mdtext: UTType { UTType(filenameExtension: "mdtext")! }
    static var markdown: UTType { UTType(filenameExtension: "markdown")! }
}

// MARK: NSRange Form Range
extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
