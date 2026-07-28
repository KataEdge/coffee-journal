import SwiftUI

public struct FlavorTagView: View {
    public let tags: [String]
    public var selectedTags: Set<String> = []
    public var onSelectTag: ((String) -> Void)?

    public init(tags: [String], selectedTags: Set<String> = [], onSelectTag: ((String) -> Void)? = nil) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.onSelectTag = onSelectTag
    }

    public var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                let isSelected = selectedTags.contains(tag)
                Button {
                    onSelectTag?(tag)
                } label: {
                    Text("#\(tag)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.amberAccent : Color.secondary.opacity(0.12))
                        )
                        .foregroundColor(isSelected ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// Simple FlowLayout for wrap-around tags
public struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                height += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    FlavorTagView(tags: ["Floral", "Citrus", "Chocolate", "Berry", "Nutty", "Jasmine"], selectedTags: ["Floral", "Citrus"])
        .padding()
}
