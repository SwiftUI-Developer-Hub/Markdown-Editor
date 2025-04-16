//
//  SheetView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/10/25.
//

import SwiftUI

struct SheetView: View {
    enum InsertType {
        case link
        case image
    }

    // Local state for labels and placeholders.
    @State private var url: String = ""
    @State private var name: String = ""
    @State private var title: String = ""
    @State private var placeholder: String = ""
    @State private var urlPlaceholder: String = ""

    // Determines the insertion type.
    var insertType: InsertType

    // The closure takes no parameters as you can capture required state from the context.
    var action: (_ name: String, _ url: String) -> Void

    // Dismiss action from the environment.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            Text("Insert \(title)")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
            
            TextField("\(placeholder) (optional)", text: $name)
                .textContentType(.name)
                .autocorrectionDisabled()
                .speechSpellsOutCharacters(true)
                .help("Enter your display name (optional)")

            TextField("https://example.com\(urlPlaceholder)", text: $url)
                .textContentType(.URL)
                .autocorrectionDisabled()
                .speechSpellsOutCharacters(true)
                .help("Enter a valid URL, including https://")

            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                .tint(Color(
                    light: Color(rgba: 0xf7f7_f9ff),
                    dark: Color(rgba: 0x2526_2aff)
                ))
                .help("Cancel and close this dialog without making changes")
                
                Button("Insert") {
                    if !url.isEmpty {
                        self.action(name, url)
                        dismiss()
                    }
                }
                .tint(url.isEmpty
                      ? Color(light: Color(rgba: 0x6b6e_7bff), dark: Color(rgba: 0x6d70_7dff))
                      : Color(light: Color(rgba: 0x2c65_cfff), dark: Color(rgba: 0x4c8e_f8ff)))
                .disabled(url.isEmpty)
                .help(url.isEmpty
                      ? "Enter a URL before inserting"
                      : "Insert the link and close this dialog")
            }
        }
        .padding()
        .background(Color(light: .white, dark: Color(rgba: 0x1819_1dff)))
        .buttonStyle(mdEditorButtonStyle())
        .textFieldStyle(mdEditorTextFieldStyle())
        .onAppear {
            switch insertType {
            case .link:
                title = "Link URL"
                placeholder = "Link Name"
            case .image:
                title = "Image URL"
                placeholder = "Image Name"
                urlPlaceholder = "/image.png"
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedRange: Range<String.Index>?
    SheetView(insertType: .image ) {name,url in

    }
}

