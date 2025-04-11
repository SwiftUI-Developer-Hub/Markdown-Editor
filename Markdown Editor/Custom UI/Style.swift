//
//  Style.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/11/25.
//

import SwiftUI

struct mdEditorButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .background(.tint, in: .rect(cornerRadius: 5))
    }
}

struct mdEditorTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .textFieldStyle(.plain)
            .padding()
            .background(Color(light: Color(rgba: 0xd0d0_d3ff), dark: Color(rgba: 0x3334_38ff)), in: .rect(cornerRadius: 5))
    }
}
