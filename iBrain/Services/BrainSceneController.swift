import Foundation
import RealityKit
import SwiftUI
import UIKit

/// Owns the RealityKit scene: loading the USDZ, indexing prims, selection,
/// highlighting, visibility and camera framing. The SwiftUI layer only calls
/// into this object.
@MainActor
final class BrainSceneController: ObservableObject {

    enum Phase: Equatable {
        case loading
        case ready
        case failed(String)
    }

    // MARK: Published state
    @Published private(set) var phase: Phase = .loading
    @Published private(set) var selected: AtlasStructure?
    @Published private(set) var hiddenIDs: Set<String> = []
    @Published private(set) var isLoadingModel = false
    @Published private(set) var structureCount = 0

    // MARK: Scene
    private weak var arView: ARView?
    private var cameraAnchor: AnchorEntity?
    private var modelRoot: Entity?
    private var structureMeshes: [String: [Entity]] = [:]
    private var structureContainers: [String: Entity] = [:]
    private var normalizedNameIndex: [String: String] = [:]
    private var rawNameIndex: [String: String] = [:]
    private var highlightOverlays: [Entity] = []
    private var originalMaterials: [String: [RealityKit.Material]] = [:]

    // MARK: Camera state
    private let defaultDistance: Float = 0.62
    private let minDistance: Float = 0.30
    private let maxDistance: Float = 0.95
    private let cameraHeight: Float = -0.02      // lifts the brain above the info card
    private let initialYaw: Float = {
        #if DEBUG
        if let arg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-yaw=") }),
           let value = Float(arg.dropFirst(5)) {
            return value
        }
        #endif
        return -0.58
    }()
    private var currentDistance: Float = 0.62
    private var yaw: Float = 0
    private var pitch: Float = 0
    private var pinchStartDistance: Float = 0.62

    // MARK: Atlas
    private(set) var atlas: AtlasIndex?
    private(set) var loadErrorMessage: String?

    private let modelName = "neuroverse_zanatomy_optimized"
    private var didStartLoading = false

    var isReady: Bool { phase == .ready }
    var hiddenCount: Int { hiddenIDs.count }

    // MARK: - Lifecycle

    func attach(arView: ARView) {
        self.arView = arView
        configureSceneIfNeeded()
        loadIfNeeded()
    }

    private func configureSceneIfNeeded() {
        guard let arView, cameraAnchor == nil else { return }
        yaw = initialYaw

        arView.environment.background = .color(UIColor(Theme.background))
        arView.renderOptions.insert(.disableMotionBlur)
        arView.renderOptions.insert(.disableDepthOfField)
        arView.renderOptions.insert(.disableGroundingShadows)

        let anchor = AnchorEntity(world: .zero)
        let camera = PerspectiveCamera()
        camera.camera.fieldOfViewInDegrees = 36
        camera.camera.near = 0.01
        camera.camera.far = 20
        anchor.addChild(camera)
        anchor.position = [0, cameraHeight, defaultDistance]
        arView.scene.addAnchor(anchor)
        cameraAnchor = anchor

        // Soft key light from upper-left-front.
        let key = DirectionalLight()
        key.light.intensity = 3200
        key.light.color = UIColor(white: 1.0, alpha: 1.0)
        key.orientation = simd_mul(
            simd_quatf(angle: .pi / 3.4, axis: [1, 0, 0]),
            simd_quatf(angle: -.pi / 4, axis: [0, 1, 0])
        )
        anchor.addChild(key)

        // Cool fill from the opposite side keeps the silhouette readable.
        let fill = DirectionalLight()
        fill.light.intensity = 1100
        fill.light.color = UIColor(red: 0.86, green: 0.88, blue: 1.0, alpha: 1.0)
        fill.orientation = simd_mul(
            simd_quatf(angle: .pi / 2.6, axis: [1, 0, 0]),
            simd_quatf(angle: .pi / 2.6, axis: [0, 1, 0])
        )
        anchor.addChild(fill)
    }

    // MARK: - Loading

    func loadIfNeeded() {
        guard !didStartLoading else { return }
        didStartLoading = true
        Task { await load() }
    }

    func retry() {
        didStartLoading = false
        phase = .loading
        loadErrorMessage = nil
        loadIfNeeded()
    }

    private func load() async {
        phase = .loading
        isLoadingModel = true
        defer { isLoadingModel = false }

        // Manifest first — it is tiny and tells us the prim names to expect.
        do {
            atlas = try AtlasRepository.load()
            structureCount = atlas?.structures.count ?? 0
        } catch {
            atlas = nil
            loadErrorMessage = error.localizedDescription
        }

        guard let arView else {
            phase = .failed("Viewer not ready")
            return
        }

        if atlas == nil {
            phase = .failed(loadErrorMessage ?? "The anatomy manifest could not be read.")
            return
        }

        do {
            let root = try await loadModelEntity()

            // The atlas is authored Z-up; stand it up for RealityKit's Y-up world.
            root.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])

            let pivot = Entity()
            pivot.name = "BrainPivot"
            pivot.addChild(root)
            pivot.orientation = simd_quatf(angle: initialYaw, axis: [0, 1, 0])
            modelRoot = pivot

            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(pivot)
            arView.scene.addAnchor(anchor)

            indexStructures(in: root)

            // RealityKit hit-tests against collision shapes; a USDZ ships none.
            root.generateCollisionShapes(recursive: true)

            if structureMeshes.isEmpty {
                phase = .failed("The model loaded but no anatomical structures were found inside it.")
                return
            }
            phase = .ready
            loadErrorMessage = nil

            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-demoDetail"),
               let first = atlas?.structures.first(where: { $0.displayName == "Hippocampus" }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                    self?.select(first)
                }
            }
            if ProcessInfo.processInfo.arguments.contains("-demoClear") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
                    self?.clearSelection()
                }
            }
            if ProcessInfo.processInfo.arguments.contains("-demoHide") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
                    self?.hideSelected()
                }
            }
            if let arg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-hitTestPoint=") }) {
                let parts = arg.dropFirst("-hitTestPoint=".count).split(separator: ",")
                if parts.count == 2, let fx = Double(parts[0]), let fy = Double(parts[1]) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak arView] in
                        guard let self, let arView else { return }
                        self.handleTap(at: CGPoint(x: arView.bounds.width * fx, y: arView.bounds.height * fy))
                    }
                }
            }
            if ProcessInfo.processInfo.arguments.contains("-hitTestCenter") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak arView] in
                    guard let self, let arView else { return }
                    self.handleTap(at: CGPoint(x: arView.bounds.midX, y: arView.bounds.midY))
                }
            }
            #endif
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    private func loadModelEntity() async throws -> Entity {
        if let entity = try? await Entity.load(named: modelName, in: .main) {
            return entity
        }
        // Fallback: explicit file lookup (folder reference / subdirectory).
        if let url = Bundle.main.url(forResource: modelName, withExtension: "usdz")
            ?? Bundle.main.url(forResource: modelName, withExtension: "usdz", subdirectory: "Brain") {
            return try await Entity.load(contentsOf: url)
        }
        throw NSError(
            domain: "iBrain.Model",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "\(modelName).usdz was not found in the app bundle."]
        )
    }

    /// Walks the entity tree and maps prim names (and their parent Xform names)
    /// onto atlas structure ids.
    private func indexStructures(in root: Entity) {
        guard let atlas else { return }

        var lookup: [String: String] = [:]
        for structure in atlas.structures {
            lookup[Self.normalize(structure.id)] = structure.id
            lookup[Self.normalize(structure.displayName)] = structure.id
        }
        normalizedNameIndex = lookup

        var meshes: [String: [Entity]] = [:]
        var containers: [String: Entity] = [:]
        var rawNames: [String: String] = [:]
        var sampleNames: [String] = []

        func match(_ rawName: String) -> String? {
            var key = Self.normalize(rawName)
            if let hit = lookup[key] { return hit }
            // Blender/RealityKit may append numeric suffixes to duplicated prim names.
            while let last = key.last, last.isNumber {
                key.removeLast()
                if let hit = lookup[key] { return hit }
            }
            return nil
        }

        func visit(_ entity: Entity) {
            if entity.components.has(ModelComponent.self) {
                if sampleNames.count < 12 { sampleNames.append("\(entity.name) <- \(entity.parent?.name ?? "nil")") }
                let candidates = [entity.name, entity.parent?.name ?? ""]
                for name in candidates where !name.isEmpty {
                    if let id = match(name) {
                        meshes[id, default: []].append(entity)
                        if containers[id] == nil { containers[id] = entity.parent ?? entity }
                        rawNames[name] = id
                        break
                    }
                }
            }
            for child in entity.children { visit(child) }
        }
        visit(root)

        if meshes.isEmpty {
            print("[iBrain] NO MATCH. Model prim names sample: \(sampleNames)")
            let expected = atlas.structures.prefix(3).map { $0.id }
            print("[iBrain] expected e.g.: \(expected)")
            Self.writeDebug("model names: \(sampleNames)\nexpected: \(expected)")
        }

        structureMeshes = meshes
        structureContainers = containers
        rawNameIndex = rawNames

        // Cache untouched materials so highlight can always be undone.
        for (id, entities) in meshes {
            var mats: [RealityKit.Material] = []
            for entity in entities {
                if let component = entity.components[ModelComponent.self] {
                    mats.append(contentsOf: component.materials)
                }
            }
            if !mats.isEmpty { originalMaterials[id] = mats }
        }

        print("[iBrain] indexed \(meshes.count) structures from model (atlas has \(atlas.structures.count))")
        Self.writeDebug("indexed=\(meshes.count) of \(atlas.structures.count)\nsample=\(meshes.keys.sorted().prefix(6))")
    }

    /// Temporary diagnostics: writes to Documents so it can be read from the simulator.
    static func writeDebug(_ text: String) {
        #if !DEBUG
        return
        #else
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        try? text.write(to: dir.appendingPathComponent("ibrain_debug.txt"), atomically: true, encoding: .utf8)
        #endif
    }

    static func normalize(_ name: String) -> String {
        name.lowercased().filter { $0.isLetter || $0.isNumber }
    }

    // MARK: - Selection

    func handleTap(at point: CGPoint) {
        guard let arView, phase == .ready else { return }
        let hits = arView.hitTest(point, query: .nearest, mask: .default)

        var chain: [String] = []
        if let first = hits.first?.entity {
            var cursor: Entity? = first
            while let node = cursor, chain.count < 4 {
                chain.append(node.name.isEmpty ? "<unnamed>" : node.name)
                cursor = node.parent
            }
        }
        print("[iBrain] tap hits=\(hits.count) chain=\(chain)")

        guard let hit = hits.first else {
            clearSelection()
            return
        }

        var node: Entity? = hit.entity
        while let current = node {
            let id = rawNameIndex[current.name] ?? normalizedNameIndex[Self.normalize(current.name)]
            if let id, let structure = atlas?.structure(id: id) {
                select(structure)
                return
            }
            node = current.parent
        }
        clearSelection()
    }

    func select(_ structure: AtlasStructure) {
        guard selected?.id != structure.id else { return }
        applyHighlight(to: structure.id)
        withAnimation(.easeInOut(duration: 0.25)) {
            selected = structure
        }
    }

    func clearSelection() {
        applyHighlight(to: nil)
        withAnimation(.easeInOut(duration: 0.25)) {
            selected = nil
        }
    }

    /// Highlighting is done with a cloned overlay instead of mutating the shipped
    /// materials: a USDZ mesh's ModelComponent cannot be reliably restored after a
    /// swap, and an overlay is trivially reversible.
    private func applyHighlight(to id: String?) {
        clearHighlightOverlay()
        guard let id, let entities = structureMeshes[id] else { return }

        var highlight = PhysicallyBasedMaterial()
        highlight.baseColor = .init(tint: UIColor(red: 0.52, green: 0.45, blue: 0.87, alpha: 1.0))
        highlight.emissiveColor = .init(color: UIColor(red: 0.30, green: 0.24, blue: 0.62, alpha: 1.0))
        highlight.emissiveIntensity = 0.65
        highlight.roughness = 0.30
        highlight.metallic = 0.0

        for entity in entities {
            guard let parent = entity.parent, entity.components.has(ModelComponent.self) else { continue }
            let overlay = entity.clone(recursive: false)
            overlay.name = "highlight-overlay"
            if var model = overlay.components[ModelComponent.self] {
                model.materials = [highlight]
                overlay.components.set(model)
            }
            overlay.scale = entity.scale * 1.004          // sits just proud of the surface
            overlay.position = entity.position
            overlay.orientation = entity.orientation
            overlay.components.remove(CollisionComponent.self)
            parent.addChild(overlay)
            highlightOverlays.append(overlay)
        }
    }

    private func clearHighlightOverlay() {
        for overlay in highlightOverlays {
            overlay.removeFromParent()
        }
        highlightOverlays.removeAll()
    }

    // MARK: - Visibility

    func hide(_ id: String) {
        guard let entity = structureContainers[id] ?? structureMeshes[id]?.first else { return }
        entity.isEnabled = false
        hiddenIDs.insert(id)
        if selected?.id == id { clearSelection() }
    }

    func showAll() {
        for id in hiddenIDs {
            (structureContainers[id] ?? structureMeshes[id]?.first)?.isEnabled = true
        }
        hiddenIDs.removeAll()
    }

    func hideSelected() {
        guard let selected else { return }
        hide(selected.id)
    }

    // MARK: - Camera

    func rotate(deltaX: CGFloat, deltaY: CGFloat) {
        guard let modelRoot else { return }
        yaw -= Float(deltaX) * 0.010
        pitch -= Float(deltaY) * 0.008
        pitch = min(max(pitch, -1.05), 1.05)

        let qYaw = simd_quatf(angle: yaw, axis: [0, 1, 0])
        let qPitch = simd_quatf(angle: pitch, axis: [1, 0, 0])
        modelRoot.orientation = simd_mul(qYaw, qPitch)
    }

    func beginPinch() { pinchStartDistance = currentDistance }

    func updatePinch(scale: CGFloat) {
        guard let cameraAnchor, scale > 0 else { return }
        let proposed = pinchStartDistance / Float(scale)
        currentDistance = min(max(proposed, minDistance), maxDistance)
        var transform = cameraAnchor.transform
        transform.translation = [0, cameraHeight, currentDistance]
        cameraAnchor.transform = transform
    }

    func resetCamera(animated: Bool = true) {
        guard let cameraAnchor else { return }
        yaw = initialYaw
        pitch = 0
        currentDistance = defaultDistance

        if animated, let modelRoot {
            var target = modelRoot.transform
            target.rotation = simd_mul(
                simd_quatf(angle: initialYaw, axis: [0, 1, 0]),
                simd_quatf(angle: 0, axis: [1, 0, 0])
            )
            modelRoot.move(to: target, relativeTo: modelRoot.parent, duration: 0.5, timingFunction: .easeInOut)

            var camTarget = cameraAnchor.transform
            camTarget.translation = [0, cameraHeight, defaultDistance]
            cameraAnchor.move(to: camTarget, relativeTo: cameraAnchor.parent, duration: 0.5, timingFunction: .easeInOut)
        } else {
            modelRoot?.orientation = simd_quatf(angle: initialYaw, axis: [0, 1, 0])
            var transform = cameraAnchor.transform
            transform.translation = [0, cameraHeight, defaultDistance]
            cameraAnchor.transform = transform
        }
    }

    func resetEverything() {
        showAll()
        clearSelection()
        resetCamera()
    }
}
