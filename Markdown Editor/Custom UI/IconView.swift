//
//  IconView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/10/25.
//

import SwiftUI

struct IconView: View {
    var lebel: String = ""
    var icon: String = ""
    var isAtive: Bool = false

    init(_ lebel: String = "", icon: String = "", isAtive: Bool = false) {
        self.icon = icon
        self.lebel = lebel
        self.isAtive = isAtive
    }

    var body: some View {
        Label(lebel, systemImage: icon)
            .help("Insert \(lebel)")
            .foregroundStyle(isAtive ? .white : .gray)
    }
}

#Preview {
    IconView()
}
