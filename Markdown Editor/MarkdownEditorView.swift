import SwiftUI
import MarkdownUI

struct MarkdownEditorView: View {
    @Binding var markdownText: String
    @Binding var selection: TextSelection?
    @State private var showingInsertLink = false
    @State private var showingInsertImage = false
    @State private var selectedHeaderLevel: Int = 0
    @State private var markdown: [String] = []
    @State private var tracker: MarkdownTracker?
    @State private var processor: MarkdownProcessor?
    @State private var selectedRange: Range<String.Index>?
    @FocusState private var focusState: Bool
    private var color = Color(light: .white, dark: Color(rgba: 0x1819_1dff))

    init(markdownText: Binding<String>, selection: Binding<TextSelection?>) {
        _selection = selection
        _markdownText = markdownText
    }

    var body: some View {
        HSplitView {
            TextView(text: $markdownText, selection: $selection)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .onChange(of: selection) {_, newSelection in
                    guard let newSelection = newSelection else { return }
                    
                    switch newSelection.indices {
                    case .selection(let range):
                        selectedRange = range
                    case .multiSelection(let rangeSet):
                        rangeSet.ranges.forEach { range in
                            selectedRange = range
                        }
                        
                    @unknown default:
                        break
                    }
                }
                .focused($focusState)
                .scrollDisabled(true)
                .scrollIndicators(.hidden)
            ScrollView(){
                Markdown(markdownText)
                    .padding(8)
                    .markdownTheme(.gitMac)
                    .markdownSoftBreakMode(.lineBreak)
                    .markdownBulletedListMarker(.circle)
                    .markdownNumberedListMarker(.decimal)
                    .markdownTaskListMarker(.checkmarkSquare)
                    .markdownCodeSyntaxHighlighter(.plainText)
                    .markdownMargin(top: .em(0), bottom: .em(0))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .background(color)
        .font(.largeTitle)
        .fontDesign(.monospaced)
        .textEditorStyle(.plain)
        .scrollIndicators(.automatic)
        .toolbarBackground(color, for: .windowToolbar)
        .toolbar {
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .bold) {range in
                    selectedRange = range
                }
            } label: {
                IconView("bold", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .italic)
            } label: {
                IconView("italic", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .strikethrough)
            } label: {
                IconView("strikethrough", isAtive: false)
            }
            Picker("Header Level", selection: $selectedHeaderLevel) {
                ForEach(0..<7, id: \.self) { level in
                    Text(level == 0 ? "None" : String(repeating: "#", count: level))
                        .tag(level)
                }
            }
            .onChange(of: selectedHeaderLevel) { _, newValue in
                if newValue == 0 {
                    // No header is selected, so don't add any `#`
                    markdown = ["", ""]
                } else {
                    processor?.applyMarkdownToSelection(range: selectedRange, type: .header(level: newValue))
                }
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .listItem)
            } label: {
                IconView("list.bullet", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .numberedItem)
            } label: {
                IconView("list.number", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .checklist)
            } label: {
                IconView("checklist.checked", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .blockquote)
            } label: {
                IconView("text.quote", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .code)
            } label: {
                IconView("chevron.left.forwardslash.chevron.right", isAtive: false)
            }
            Button {
                processor?.applyMarkdownToSelection(range: selectedRange, type: .table(top: "|   |   |", middle: "|---|---|", bottom: "|   |   |"))
            } label: {
                IconView("table", isAtive: false)
            }
            Button {
                let range = selectedRange ?? markdownText.startIndex..<markdownText.startIndex
                let selectedText = String(markdownText[range])
                if range.isEmpty {
                    showingInsertLink = true
                } else {
                    processor?.applyMarkdownToSelection(range: selectedRange, type: .link(linkName: selectedText, url: selectedText))
                }
            } label: {
                IconView("link", isAtive: false)
            }
            Button {
                let range = selectedRange ?? markdownText.startIndex..<markdownText.startIndex
                let selectedText = String(markdownText[range])
                if range.isEmpty {
                    showingInsertImage = true
                } else {
                    processor?.applyMarkdownToSelection(range: selectedRange, type: .image(imageName: selectedText, url: selectedText))
                }
            } label: {
                IconView("photo", isAtive: false)
            }
        }
        .sheet(isPresented: $showingInsertLink){
            SheetView(insertType: .link) {name,url in
                processor?.applyMarkdownToSelection(range: selectedRange, type: .link(linkName: name, url: url))
            }
            .presentationCornerRadius(20)
        }
        .sheet(isPresented: $showingInsertImage){
            SheetView(insertType: .image) {name,url in
                processor?.applyMarkdownToSelection(range: selectedRange, type: .image(imageName: name, url: url))
            }
            .presentationCornerRadius(20)
        }
        .onAppear {
            self.processor = MarkdownProcessor(markdownText: self.$markdownText)
            self.focusState = true
        }
    }
}

struct MarkdownEditorView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownEditorView(markdownText: .constant("![aaa](http://192.168.1.86:84/wp-content/uploads/2025/02/r7gqr1jdqwxa1.jpg)"), selection: .constant(nil))
    }
}
