//
//  Extensions.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/12/25.
//

import SwiftUI
import Foundation

func isDebug() -> Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}

func toggleSetting(selector: Selector) {
    NSApp.sendAction(selector, to: nil, from: nil)
}

func misspelledWord(at index: Int, in text: String) -> (word: String, range: NSRange)? {
    guard !text.isEmpty, index < text.utf16.count else { return nil }

    let nsText = text as NSString

    // Use linguistic tagger to find the word at the given index
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
    tagger.string = text

    var wordRange = NSRange(location: NSNotFound, length: 0)

    tagger.enumerateTags(
        in: NSRange(location: 0, length: nsText.length),
        unit: .word,
        scheme: .tokenType,
        options: [.omitPunctuation, .omitWhitespace]
    ) { _, tokenRange, _ in
        if NSLocationInRange(index, tokenRange) {
            wordRange = tokenRange
        }
    }

    guard wordRange.location != NSNotFound else { return nil }

    let word = nsText.substring(with: wordRange)

    // Check if just this word is misspelled — don't scan from index
    let wordIsMisspelled = NSSpellChecker.shared.checkSpelling(
        of: word,
        startingAt: 0
    ).location != NSNotFound

    return wordIsMisspelled ? (word, wordRange) : nil
}

func suggestions(for word: String) -> [String] {
    // Return empty array if no suggestions are available
    return NSSpellChecker.shared.guesses(forWordRange: NSRange(location: 0, length: word.count),
                                         in: word,
                                         language: "en_US",
                                         inSpellDocumentWithTag: 0) ?? []
}
