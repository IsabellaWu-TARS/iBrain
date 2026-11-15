import SwiftUI

// MARK: - Design System
struct BrainDesign {
    
    // MARK: - Color System
    struct Colors {
        // Light Mode
        static let lightBackground = Color(hex: "FFFDF7")
        static let lightCard = Color.white.opacity(0.65)
        static let lightGlass = Color.white.opacity(0.4)
        
        // Dark Mode
        static let darkBackground = Color(hex: "111111")
        static let darkCard = Color(hex: "232323").opacity(0.7)
        
        // Accent
        static let accent = Color(hex: "A2A569")
        static let accentSecondary = Color(hex: "8B8B5A")
        
        // Brain Highlights
        static let brainPurple = Color(hex: "9B8DC9")
        static let brainBlue = Color(hex: "7BA3C9")
        static let brainGreen = Color(hex: "7BC9A3")
        static let brainPink = Color(hex: "C98BB5")
        static let brainOrange = Color(hex: "C9A37B")
        
        // Typography
        static let primaryText = Color(hex: "111111")
        static let secondaryText = Color(hex: "6B6B6B")
        
        // Semantic
        static let memoryColor = Color(hex: "9B8DC9")
        static let focusColor = Color(hex: "7BA3C9")
        static let emotionColor = Color(hex: "C98BB5")
        static let learningColor = Color(hex: "7BC9A3")
        static let decisionColor = Color(hex: "C9A37B")
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let sectionTitle = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let cardTitle = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 20
        static let large: CGFloat = 28
        static let xlarge: CGFloat = 36
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let light = Shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        static let medium = Shadow(color: .black.opacity(0.12), radius: 30, x: 0, y: 15)
        static let heavy = Shadow(color: .black.opacity(0.15), radius: 40, x: 0, y: 20)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions
extension View {
    func brainGlassBackground(isLight: Bool = true) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: BrainDesign.CornerRadius.large)
                .fill(isLight ? BrainDesign.Colors.lightGlass : BrainDesign.Colors.darkCard)
                .overlay(
                    RoundedRectangle(cornerRadius: BrainDesign.CornerRadius.large)
                        .fill(.white.opacity(isLight ? 0.3 : 0.1))
                )
        )
        .shadow(
            color: BrainDesign.Shadows.light.color,
            radius: BrainDesign.Shadows.light.radius,
            x: BrainDesign.Shadows.light.x,
            y: BrainDesign.Shadows.light.y
        )
    }
    
    func brainCard() -> some View {
        self.brainGlassBackground()
            .clipShape(RoundedRectangle(cornerRadius: BrainDesign.CornerRadius.large))
    }
}
