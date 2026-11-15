import SwiftUI

struct LearnView: View {
    private let topics: [Topic] = [
        Topic(title: "Memory & Learning", subtitle: "How experience becomes structure",
              systemName: "brain.head.profile", tint: Color(hex: "8B87C4")),
        Topic(title: "Emotions", subtitle: "The limbic circuits behind feeling",
              systemName: "heart", tint: Color(hex: "C48B8B")),
        Topic(title: "Sleep", subtitle: "What the brain does while you rest",
              systemName: "moon.stars", tint: Color(hex: "7C8DB5")),
        Topic(title: "Brain & Movement", subtitle: "From intention to motion",
              systemName: "figure.walk", tint: Color(hex: "8BB5A0")),
        Topic(title: "Neuroplasticity", subtitle: "How the brain rewires itself",
              systemName: "arrow.triangle.2.circlepath", tint: Color(hex: "C4B08B"))
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.l) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Learn")
                        .font(Theme.Fonts.display)
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(-0.8)
                    Text("Short, careful explanations of how the brain works")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, Theme.Space.xs)

                VStack(spacing: Theme.Space.s) {
                    ForEach(topics) { topic in
                        TopicCard(topic: topic)
                    }
                }

                Text("Full lessons arrive in a later version.")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Theme.Space.s)
            }
            .padding(.horizontal, Theme.Space.m)
            .padding(.bottom, Theme.Space.xl)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    struct Topic: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemName: String
        let tint: Color
    }

    private struct TopicCard: View {
        let topic: Topic

        var body: some View {
            HStack(spacing: Theme.Space.m) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(topic.tint.opacity(0.14))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: topic.systemName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(topic.tint)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(topic.title)
                        .font(Theme.Fonts.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text(topic.subtitle)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Text("Soon")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Theme.background))
            }
            .padding(Theme.Space.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface(radius: 20)
        }
    }
}
