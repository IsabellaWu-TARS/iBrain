import Foundation

/// One selectable anatomical prim of the USDZ brain.
/// `id` is the USD prim name (sanitised), which is also what RealityKit reports.
struct AtlasStructure: Identifiable, Hashable {
    let id: String              // usd_node_name, e.g. "Precentral_gyrus__Left_"
    let nodeName: String        // human name from the atlas, e.g. "Precentral gyrus (Left)"
    let group: String           // "Cerebral Cortex", "Cerebellum", ...
    let side: String            // "Left" | "Right" | "Midline"
    let region: String          // "intact" | "internal"
    let triangles: Int
    let primPath: String

    var displayName: String {
        nodeName
            .replacingOccurrences(of: " (Left)", with: "")
            .replacingOccurrences(of: " (Right)", with: "")
    }

    var sideLabel: String { side == "Midline" ? "Midline" : "\(side) side" }
}

/// Visual metadata for each anatomical system.
struct AtlasGroupStyle {
    let title: String
    let systemImage: String

    static func style(for group: String) -> AtlasGroupStyle {
        switch group {
        case "Cerebral Cortex":     return .init(title: "Cerebral cortex", systemImage: "brain.head.profile")
        case "Cerebellum":          return .init(title: "Cerebellum", systemImage: "circle.hexagongrid")
        case "Brainstem":           return .init(title: "Brainstem", systemImage: "arrow.down.to.line")
        case "Diencephalon":        return .init(title: "Diencephalon", systemImage: "circle.grid.cross")
        case "Basal Ganglia":       return .init(title: "Basal ganglia", systemImage: "circle.hexagonpath")
        case "Limbic System":       return .init(title: "Limbic system", systemImage: "heart")
        case "White Matter":        return .init(title: "White matter", systemImage: "line.3.horizontal")
        case "Ventricular System":  return .init(title: "Ventricular system", systemImage: "drop")
        default:                    return .init(title: group, systemImage: "circle.dashed")
        }
    }
}

/// Decoded `brain_structure_map.json` — links the app's curated content to atlas prims.
struct StructureMapping: Codable {
    let nodes: [String]
    let usdNodes: [String]
    let note: String?
    let usdGroup: String?

    enum CodingKeys: String, CodingKey {
        case nodes
        case usdNodes = "usd_nodes"
        case note
        case usdGroup = "usd_group"
    }
}

struct StructureMapFile: Codable {
    let asset: String
    let structures: [String: StructureMapping]
}

/// Result of loading the atlas resources from the bundle.
struct AtlasIndex {
    let structures: [AtlasStructure]
    let byID: [String: AtlasStructure]
    /// usd prim name -> app content id, e.g. "Hippocampus__Left_" -> "hippocampus"
    let appContentID: [String: String]
    /// Group name -> structures, in stable order.
    let groups: [(String, [AtlasStructure])]

    func structure(id: String) -> AtlasStructure? { byID[id] }
}
