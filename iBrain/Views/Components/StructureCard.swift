import SwiftUI

/// Floating card under the brain: selection details, or the idle instruction.
struct StructureCard: View {
    let structure: AtlasStructure?
    let onLearnMore: () -> Void
    let onHide: () -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Space.m) {
            if let structure {
                selectedContent(structure)
            } else {
                idleContent
            }
        }
        .padding(Theme.Space.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: structure?.id)
    }

    // MARK: Selected
    private func selectedContent(_ structure: AtlasStructure) -> some View {
        let style = AtlasGroupStyle.style(for: structure.group)
        return VStack(alignment: .leading, spacing: Theme.Space.s) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(structure.displayName)
                        .font(Theme.Fonts.title)
                        .foregroundStyle(Theme.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(structure.sideLabel)
                        .font(Theme.Fonts.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer(minLength: Theme.Space.s)
                Button(action: onClear) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Theme.background))
                }
                .buttonStyle(.plain)
            }

            CategoryPill(title: style.title, systemName: style.systemImage)

            Text(StructureCopy.summary(for: structure))
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: Theme.Space.s) {
                Button(action: onLearnMore) {
                    Text("Learn more")
                        .font(Theme.Fonts.label)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(Capsule(style: .continuous).fill(Theme.accent))
                }
                .buttonStyle(.plain)

                Button(action: onHide) {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Hide")
                            .font(Theme.Fonts.label)
                    }
                    .foregroundStyle(Theme.textPrimary.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Capsule(style: .continuous).fill(Theme.background))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.top, 2)
        }
        .transition(.opacity)
    }

    // MARK: Idle
    private var idleContent: some View {
        HStack(spacing: 14) {
            Image(systemName: "hand.tap")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Theme.accent)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.accentSoft))

            VStack(alignment: .leading, spacing: 3) {
                Text("Tap any region to explore")
                    .font(Theme.Fonts.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("Drag to rotate · Pinch to zoom")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .transition(.opacity)
    }
}

/// Detail sheet shown from "Learn more".
struct StructureDetailSheet: View {
    let structure: AtlasStructure
    let content: BrainStructure?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.l) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(structure.displayName)
                            .font(Theme.Fonts.display)
                            .foregroundStyle(Theme.textPrimary)
                        Text(AtlasGroupStyle.style(for: structure.group).title + " · " + structure.sideLabel)
                            .font(Theme.Fonts.body)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Text(StructureCopy.summary(for: structure))
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textPrimary.opacity(0.85))
                        .lineSpacing(5)

                    if let content {
                        section("Functions") {
                            bulletList(content.functions)
                        }
                        section("In daily life") {
                            bulletList(content.realLifeImpact)
                        }
                        section("Clinical relevance") {
                            Text(content.clinicalRelevance)
                                .font(Theme.Fonts.body)
                                .foregroundStyle(Theme.textSecondary)
                                .lineSpacing(4)
                        }
                    }

                    section("Atlas detail") {
                        VStack(alignment: .leading, spacing: 6) {
                            detailRow("System", AtlasGroupStyle.style(for: structure.group).title)
                            detailRow("Side", structure.sideLabel)
                            detailRow("Triangles", "\(structure.triangles)")
                            detailRow("Prim", structure.id)
                        }
                    }
                }
                .padding(Theme.Space.l)
            }
            .background(Theme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(Theme.Fonts.label)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.s) {
            Text(title.uppercased())
                .font(Theme.Fonts.caption)
                .tracking(1.1)
                .foregroundStyle(Theme.textTertiary)
            content()
        }
    }

    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(Theme.accent.opacity(0.5))
                        .frame(width: 5, height: 5)
                        .padding(.top, 7)
                    Text(item)
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}
