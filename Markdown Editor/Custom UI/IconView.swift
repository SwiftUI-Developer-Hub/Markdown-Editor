//
//  IconView.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/10/25.
//

import SwiftUI

struct IconView: View {
    var icon: String = ""
    var isAtive: Bool = false

    init(_ icon: String = "", isAtive: Bool = false) {
        self.icon = icon
        self.isAtive = isAtive
    }
    var body: some View {
        Image(systemName: icon)
            .imageScale(.large)
            .foregroundStyle(isAtive ? .white : .gray)
    }
}

#Preview {
    IconView()
}
