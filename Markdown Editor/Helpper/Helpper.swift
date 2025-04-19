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

    // Setup LinguisticTagger
    let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
    tagger.string = text

    // Convert index to String.Index
    let stringIndex = text.utf16.index(text.utf16.startIndex, offsetBy: index)
    let utf16Offset = text.utf16.distance(from: text.utf16.startIndex, to: stringIndex)
    var wordRange = NSRange(location: NSNotFound, length: 0)

    tagger.enumerateTags(
        in: NSRange(location: 0, length: nsText.length),
        unit: .word,
        scheme: .tokenType,
        options: [.omitPunctuation, .omitWhitespace]
    ) { _, tokenRange, _ in
        if NSLocationInRange(utf16Offset, tokenRange) {
            wordRange = tokenRange
        }
    }

    guard wordRange.location != NSNotFound else { return nil }

    let word = nsText.substring(with: wordRange)

    let misspelledRange = NSSpellChecker.shared.checkSpelling(
        of: text,
        startingAt: wordRange.location,
        language: "en_US",
        wrap: false,
        inSpellDocumentWithTag: 0,
        wordCount: nil
    )

    guard misspelledRange.location != NSNotFound,
          NSEqualRanges(misspelledRange, wordRange) else {
        return nil
    }

    return (word, wordRange)
}

func suggestions(for word: String) -> [String]? {
    NSSpellChecker.shared.guesses(forWordRange: NSRange(location: 0, length: word.count),
                                  in: word,
                                  language: "en_US",
                                  inSpellDocumentWithTag: 0)
}
