import SwiftUI

struct MarkdownText: View {

    let raw: String

    private enum Line {
        case text(String)
        case bullet(String, indent: Int)
        case numbered(String, number: String, indent: Int)
        case blank
    }

    private var lines: [Line] {
        raw.components(separatedBy: "\n").map { rawLine -> Line in

            let spaces = rawLine.prefix(while: { $0 == " " }).count
            let indent = spaces / 2

            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty { return .blank }

            for marker in ["- ", "* ", "• "] {
                if trimmed.hasPrefix(marker) {
                    return .bullet(String(trimmed.dropFirst(marker.count)), indent: indent)
                }
            }

            if let dot = trimmed.firstIndex(of: "."),
               dot != trimmed.startIndex,
               trimmed[..<dot].allSatisfy(\.isNumber),
               trimmed[trimmed.index(after: dot)...].hasPrefix(" ") {
                let number = String(trimmed[..<dot])
                let content = String(trimmed[trimmed.index(dot, offsetBy: 2)...])
                return .numbered(content, number: number, indent: indent)
            }

            return .text(trimmed)
        }
    }

    private func inline(_ string: String) -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return (try? AttributedString(markdown: string, options: options))
            ?? AttributedString(string)
    }


    @ViewBuilder
    private func row(for line: Line) -> some View {
        switch line {

        case .text(let content):
            Text(inline(content))

        case .bullet(let content, let indent):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("•")
                Text(inline(content))
            }
            .padding(.leading, CGFloat(indent) * 16)

        case .numbered(let content, let number, let indent):
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(number).")
                Text(inline(content))
            }
            .padding(.leading, CGFloat(indent) * 16)

        case .blank:
            Color.clear.frame(height: 4)
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                row(for: line)
            }
        }
    }
}
