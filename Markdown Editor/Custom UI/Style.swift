//
//  Style.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import SwiftUI

// MARK: Button Styles
struct mdEditorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .background(.tint, in: .rect(cornerRadius: 5))
    }
}

struct mdEditorListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity, alignment:.leading)
            .background(configuration.isPressed ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear), in: .rect(cornerRadius: 5))
    }
}

// MARK: Text Field Styles
struct mdEditorTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .textFieldStyle(.plain)
            .background(Color(light: Color(rgba: 0xd0d0_d3ff), dark: Color(rgba: 0x3334_38ff)), in: .rect(cornerRadius: 5))
    }
}
