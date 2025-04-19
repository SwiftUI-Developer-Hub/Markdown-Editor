//
//  Extensions.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

extension View {
    func basicEditMenu(_ text: Binding<String>, selectedRange: Range<String.Index>?) -> some View {
        self.contextMenu {
            if let range = selectedRange {
                // Convert upperBound to utf16 offset
                let utf16Offset = range.lowerBound.utf16Offset(in: text.wrappedValue)
                
                // Call the misspelledWord function
                if let misspelled = misspelledWord(at: utf16Offset, in: text.wrappedValue),
                   let suggestions = suggestions(for: misspelled.word), !suggestions.isEmpty {
                    
                    ForEach(suggestions, id: \.self) { guess in
                        Button(guess) {
                            let nsText = text.wrappedValue as NSString
                            let replaced = nsText.replacingCharacters(in: misspelled.range, with: guess)
                            text.wrappedValue = replaced
                        }
                    }
                    Divider()

                    Button("Ignore Spelling") {
                        NSSpellChecker.shared.ignoreWord(misspelled.word, inSpellDocumentWithTag: 0)
                    }
                    .help("Ignore this word in the current document")

                    Button("Learn Spelling") {
                        NSSpellChecker.shared.learnWord(misspelled.word)
                    }
                    .help("Add this word to your custom dictionary")

                    Divider()
                }
            }

            // Core editing actions
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

            Button("Select All") {
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
            }
            .help("Select all the text")

            Divider()

            SpellingAndGrammarMenu()
        }
    }
}

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

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}
