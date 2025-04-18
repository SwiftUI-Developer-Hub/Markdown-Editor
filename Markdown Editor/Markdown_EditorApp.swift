//
//  Markdown_EditorApp.swift
//  Markdown Editor
//
//  Created by BAproductions on 4/9/25.
//
import Cocoa
import SwiftUI
import UniformTypeIdentifiers

@main
struct Markdown_EditorApp: App {
    @State private var filepath: URL?
    @State private var selection: TextSelection? = nil
    @AppStorage("isWelcome") private var isWelcome: Bool = true
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @FocusedValue(\.welecomWindowState) private var currentWindowFocusedValue: WelecomWindowState?

    var body: some Scene {
        WindowGroup("Wellcome", id: "markdownWelcomeWindow") {
            MarkdownWelcomeView()
                .windowResizeBehavior(.disabled)
                .windowMinimizeBehavior(.disabled)
                .windowMinimizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
                .focusedSceneValue(\.welecomWindowState, .active)
                .onAppear {
                    isWelcome = true
                }
        }
        .commandsRemoved()
        .windowLevel(.normal)
        .windowStyle(.hiddenTitleBar)
        .windowIdealSize(.fitToContent)
        .windowManagerRole(.automatic)
        .windowResizability(.contentSize)
        .windowToolbarLabelStyle(fixed: .titleOnly)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))

        DocumentGroup(newDocument: MarkdownFile()) { file in
            MarkdownEditorView(markdownFile: file, selection: $selection)
                .windowFullScreenBehavior(.disabled)
                .focusedSceneValue(\.welecomWindowState, .inactive)
                .onAppear {
                    isWelcome = false
                }
        }
        .commands {
            if currentWindowFocusedValue == .active {
                WelcomeCommands()
            } else {
                EditorCommands()
            }
        }
        .windowLevel(.normal)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.expanded)
        .windowIdealSize(.fitToContent)
        .windowManagerRole(.automatic)
        .windowResizability(.contentSize)
        .windowToolbarLabelStyle(fixed: .iconOnly)
    }
}
