import SwiftUI
import MarkdownUI

struct MarkdownEditorView: View {
    @Binding var markdownText: String
    @Binding var selection: TextSelection?
    @State private var isScrolling = false
    @State private var markdown: [String] = []
    @State private var showingInsertLink = false
    @State private var showingInsertImage = false
    @State private var processor: MarkdownProcessor?
    @State private var scrollTo: CGPoint = CGPoint()
    @State private var selectedHeaderLevel: Int = 0
    @State private var scrollPosition: ScrollPosition
    @Environment(\.openWindow) private var openWindow
    @Environment(\.undoManager) private var undoManager
    @State private var selectedRange: Range<String.Index>?
    @Environment(\.dismissWindow) private var dismissWindow
    private var color = Color(light: .white, dark: Color(rgba: 0x1819_1dff))

    init(markdownFile: FileDocumentConfiguration<MarkdownFile>, selection: Binding<TextSelection?>) {
        _selection = selection
        self.scrollPosition = ScrollPosition()
        _markdownText = markdownFile.$document.text
    }

    var body: some View {
        HSplitView {
            TextView(text: $markdownText, isScrolling: $isScrolling , selection: $selection, scrollPosition: .constant(scrollTo)) { position in
                self.scrollPosition.scrollTo(point: position)
            }
            .onChange(of: selection) {_, newSelection in
                guard let newSelection = newSelection else { return }
                switch newSelection.indices {
                case .selection(let range):
                    selectedRange = range
                    if isDebug() {
                        print(range)
                    }
                case .multiSelection(let rangeSet):
                    rangeSet.ranges.forEach { range in
                        selectedRange = range
                        if isDebug() {
                            print(range)
                        }
                    }
                @unknown default:
                    break
                }
            }
            .basicEditMenu($markdownText, selectedRange: selectedRange)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            ScrollView(.vertical, showsIndicators: true){
                Markdown(markdownText)
                    .markdownTheme(.gitMac)
                    .markdownSoftBreakMode(.lineBreak)
                    .markdownBulletedListMarker(.circle)
                    .markdownNumberedListMarker(.decimal)
                    .markdownTaskListMarker(.checkmarkSquare)
                    .markdownCodeSyntaxHighlighter(.plainText)
                    .markdownMargin(top: .em(0), bottom: .em(0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .contentMargins(8, for: .scrollContent)
            .onScrollPhaseChange({ _, phase in
                switch(phase){
                case .animating:
                    isScrolling = true
                case .idle:
                    isScrolling = false
                case .tracking:
                    isScrolling = true
                case .interacting:
                    isScrolling = true
                case .decelerating:
                    isScrolling = false
                }
            })
            .onScrollGeometryChange(for: CGPoint.self) { geometry in
                geometry.contentOffset
            } action: { _, newValue in
                self.scrollTo = newValue
            }
            .scrollPosition($scrollPosition)
        }
        .background(color)
        .font(.largeTitle)
        .fontDesign(.monospaced)
        .textEditorStyle(.plain)
        .scrollIndicators(.automatic)
        .toolbarBackground(color, for: .windowToolbar)
        .toolbar {
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .bold)
            } label: {
                IconView("Bold", icon: "bold", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .italic)
            } label: {
                IconView("Italic", icon:"italic", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .strikethrough)
            } label: {
                IconView("Strikethrough", icon:"strikethrough", isAtive: false)
            }
            Picker("Header Level", selection: $selectedHeaderLevel) {
                ForEach(0..<7, id: \.self) { level in
                    Text(level == 0 ? "None" : "\(String(repeating: "#", count: level)) Heading")
                        .fixedSize(horizontal: false, vertical: false)
                        .tag(level)
                }
            }
            .onChange(of: selectedHeaderLevel) { _, newValue in
                if newValue == 0 {
                    // No header is selected, so don't add any `#`
                    markdown = ["", ""]
                } else {
                    processor?.applyMarkdownToSelection(selectedRange, type: .header(level: newValue))
                }
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .listItem)
            } label: {
                IconView("Bullet List", icon: "list.bullet", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .numberedItem)
            } label: {
                IconView("Number List", icon: "list.number", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .checklist)
            } label: {
                IconView("Check Box", icon: "checklist", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .blockquote)
            } label: {
                IconView("Text Quote", icon: "text.quote", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .code)
            } label: {
                IconView("Code", icon: "chevron.left.forwardslash.chevron.right", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(selectedRange, type: .table(top: "|   |   |", middle: "|---|---|", bottom: "|   |   |"))
            } label: {
                IconView("Table", icon: "tablecells", isAtive: false)
            }
            Button {
                let range = selectedRange ?? markdownText.startIndex..<markdownText.startIndex
                let selectedText = String(markdownText[range])
                if range.isEmpty {
                    showingInsertLink = true
                } else {
                    processor?.applyMarkdownToSelection(selectedRange, type: .link(linkName: selectedText, url: selectedText))
                }
            } label: {
                IconView("Link", icon: "link", isAtive: false)
            }
            Button {
                let range = selectedRange ?? markdownText.startIndex..<markdownText.startIndex
                let selectedText = String(markdownText[range])
                if range.isEmpty {
                    showingInsertImage = true
                } else {
                    processor?.applyMarkdownToSelection(selectedRange, type: .image(imageName: selectedText, url: selectedText))
                }
            } label: {
                IconView("Photo", icon: "photo.fill", isAtive: false)
            }

            Button {
                processor?.clearAllMarkdownForSelection(selectedRange)
            } label: {
                IconView("Clear Selected Markdown", icon: "eraser.fill", isAtive: false)
            }
        }
        .sheet(isPresented: $showingInsertLink){
            SheetView(insertType: .link) {name,url in
                processor?.applyMarkdownToSelection(selectedRange, type: .link(linkName: name, url: url))
            }
            .presentationCornerRadius(20)
        }
        .sheet(isPresented: $showingInsertImage){
            SheetView(insertType: .image) {name,url in
                processor?.applyMarkdownToSelection(selectedRange, type: .image(imageName: name, url: url))
            }
            .presentationCornerRadius(20)
        }
        .onAppear {
            withAnimation(.smooth){
                dismissWindow(id: "markdownWelcomeWindow")
            }
            self.processor = MarkdownProcessor($markdownText, undoManager: undoManager)
        }
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let visibleWindowCount = NSApp.windows.filter { $0.isVisible && !$0.isKind(of: NSPanel.self) }.count
                if visibleWindowCount == 0 {
                    withAnimation(.smooth){
                        openWindow(id: "markdownWelcomeWindow")
                    }
                }
            }
        }
    }
}

