//
//  SwiftUIView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/14/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct MarkdownFile: FileDocument {
    static var readableContentTypes: [UTType] {
        [
            UTType(filenameExtension: "md")!,
            UTType(filenameExtension: "mkdn")!
        ]
    }
    static var writableContentTypes: [UTType] {
        [
            UTType(filenameExtension: "md")!,
            UTType(filenameExtension: "mkdn")!
        ]
    }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            self.text = string
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
