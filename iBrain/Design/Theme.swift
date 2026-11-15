import SwiftUI

/// Single source of truth for the visual language.
/// Warm off-white canvas, near-black text, one restrained lavender accent.
enum Theme {

    // MARK: Colour
    static let background = Color(hex: "F8F8F6")
    static let backgroundTop = Color(hex: "FBFBF9")
    static let surface = Color.white
    static let textPrimary = Color(hex: "1C1C1E")
    static let textSecondary = Color(hex: "8A8A8E")
    static let textTertiary = Color(hex: "B4B4B8")
    static let accent = Color(hex: "8B87C4")
    static let accentSoft = Color(hex: "EFEDF8")
    static let hairline = Color(hex: "E9E9E4")

    // MARK: Metrics
    enum Radius {
        static let card: CGFloat = 24
        static let control: CGFloat = 18
        static let pill: CGFloat = 100
    }

    enum Space {
        static let xs: CGFloat = 6
        static let s: CGFloat = 10
        static let m: CGFloat = 16
        static let l: CGFloat = 22
        static let xl: CGFloat = 30
    }

    // MARK: Type
    enum Fonts {
        static let display = Font.system(size: 34, weight: .semibold, design: .default)
        static let title = Font.system(size: 22, weight: .semibold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 12, weight: .medium)
        static let label = Font.system(size: 13, weight: .semibold)
    }

    // MARK: Reusable surfaces
    static let cardShadow = Color.black.opacity(0.07)
}

/// Cards, pills and controls used across the app.
struct CardBackground: ViewModifier {
    var radius: CGFloat = Theme.Radius.card
    var fill: Color = Theme.surface

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .shadow(color: Theme.cardShadow, radius: 22, x: 0, y: 10)
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            )
    }
}

extension View {
    func cardSurface(radius: CGFloat = Theme.Radius.card, fill: Color = Theme.surface) -> some View {
        modifier(CardBackground(radius: radius, fill: fill))
    }
}

/// Small circular icon button used for the viewer controls.
struct IconButton: View {
    let systemName: String
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isActive ? Theme.accent : Theme.textPrimary.opacity(0.75))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Theme.surface)
                        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
                )
        }
        .buttonStyle(.plain)
    }
}

/// Capability badge shown on the structure card.
struct CategoryPill: View {
    let title: String
    let systemName: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .semibold))
            Text(title)
                .font(Theme.Fonts.caption)
        }
        .foregroundStyle(Theme.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous).fill(Theme.accentSoft)
        )
    }
}
