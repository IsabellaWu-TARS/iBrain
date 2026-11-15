import SwiftUI

struct ExploreView: View {
    @StateObject private var controller = BrainSceneController()
    @State private var showSettings = false
    @State private var detailStructure: AtlasStructure?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            BrainViewer(controller: controller)
                .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, Theme.Space.l)
                    .padding(.top, Theme.Space.xs)

                Spacer(minLength: 0)

                viewerControls
                    .padding(.horizontal, Theme.Space.l)
                    .padding(.bottom, Theme.Space.s)

                StructureCard(
                    structure: controller.selected,
                    onLearnMore: {
                        detailStructure = controller.selected
                    },
                    onHide: { controller.hideSelected() },
                    onClear: { controller.clearSelection() }
                )
                .padding(.horizontal, Theme.Space.m)
                .padding(.bottom, Theme.Space.xs)
            }

            stateOverlay
        }
        .sheet(item: $detailStructure) { structure in
            StructureDetailSheet(
                structure: structure,
                content: controller.atlas?.appContentID[structure.id].flatMap(BrainData.structure(for:))
            )
        }
        .onAppear {
            controller.loadIfNeeded()
            #if DEBUG
            // Screenshot helper: open the detail sheet for the selected structure.
            if ProcessInfo.processInfo.arguments.contains("-demoSheet") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    detailStructure = controller.selected
                }
            }
            #endif
        }
    }

    // MARK: Header
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("iBrain")
                    .font(Theme.Fonts.display)
                    .foregroundStyle(Theme.textPrimary)
                    .tracking(-0.8)
                Text("Explore the human brain")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            IconButton(systemName: "slider.horizontal.3") {
                showSettings = true
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(controller: controller)
            }
        }
    }

    // MARK: Controls
    private var viewerControls: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                IconButton(systemName: "arrow.counterclockwise") {
                    controller.resetCamera()
                }

                if controller.hiddenCount > 0 {
                    Button {
                        controller.showAll()
                    } label: {
                        Image(systemName: "eye")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Theme.accent))
                            .shadow(color: Theme.accent.opacity(0.3), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: controller.hiddenCount)
    }

    // MARK: Loading / error
    @ViewBuilder
    private var stateOverlay: some View {
        switch controller.phase {
        case .loading:
            VStack(spacing: 14) {
                ProgressView()
                    .tint(Theme.accent)
                Text("Preparing the anatomy")
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(26)
            .cardSurface(radius: 22)
            .transition(.opacity)

        case .failed(let message):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(Theme.accent)
                Text("The 3D model could not be loaded")
                    .font(Theme.Fonts.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text(message)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                Button {
                    controller.retry()
                } label: {
                    Text("Try again")
                        .font(Theme.Fonts.label)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Theme.accent))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(26)
            .frame(maxWidth: 320)
            .cardSurface(radius: 22)
            .transition(.opacity)

        case .ready:
            EmptyView()
        }
    }
}

// MARK: - Settings

struct SettingsSheet: View {
    @ObservedObject var controller: BrainSceneController
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Space.l) {
                    group("Viewer") {
                        Button {
                            controller.resetEverything()
                            dismiss()
                        } label: {
                            row("Reset view", detail: "Recentre and show every structure", systemName: "arrow.counterclockwise")
                        }
                        .buttonStyle(.plain)
                        Button {
                            controller.showAll()
                            dismiss()
                        } label: {
                            row("Show all structures", detail: "\(controller.hiddenCount) hidden", systemName: "eye")
                        }
                        .buttonStyle(.plain)
                    }

                    group("Atlas") {
                        infoRow("Structures", "\(controller.structureCount)")
                        infoRow("Model", "Z-Anatomy brain atlas")
                        infoRow("Format", "USDZ · RealityKit")
                    }

                    group("Attribution") {
                        Text("3D brain model from Z-Anatomy — the libre 3D atlas of anatomy (CC BY-SA 4.0), derived from BodyParts3D, Database Center for Life Science (DBCLS), CC BY-SA 2.1 Japan. Subset to brain structures, renamed, regrouped and optimised for real-time rendering.")
                            .font(Theme.Fonts.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .lineSpacing(3)
                    }
                }
                .padding(Theme.Space.l)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.Space.s) {
            Text(title.uppercased())
                .font(Theme.Fonts.caption)
                .tracking(1.1)
                .foregroundStyle(Theme.textTertiary)
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(Theme.Space.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardSurface(radius: 20)
        }
    }

    private func row(_ title: String, detail: String, systemName: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.accent)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(Theme.textPrimary)
                Text(detail)
                    .font(Theme.Fonts.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Fonts.body)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Fonts.caption)
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, 8)
    }
}
