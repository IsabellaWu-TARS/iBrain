import Foundation

/// Loads the atlas manifest (CSV + mapping JSON) that ships in the bundle and
/// turns it into `AtlasStructure` values. No hard-coded prim names live in the UI.
enum AtlasRepository {

    enum LoadError: LocalizedError {
        case missingResource(String)
        case malformed(String)

        var errorDescription: String? {
            switch self {
            case .missingResource(let name): return "Missing bundled resource: \(name)"
            case .malformed(let detail): return "Malformed atlas data: \(detail)"
            }
        }
    }

    static let structuresFileName = "neuroverse_zanatomy_structures"
    static let mapFileName = "brain_structure_map"

    static func load(bundle: Bundle = .main) throws -> AtlasIndex {
        let csvURL = try resourceURL(structuresFileName, ext: "csv", bundle: bundle)
        let mapURL = try resourceURL(mapFileName, ext: "json", bundle: bundle)

        let csv = try String(contentsOf: csvURL, encoding: .utf8)
        let rows = CSVParser.parse(csv)
        guard rows.count > 1 else { throw LoadError.malformed("structure CSV is empty") }

        let header = rows[0]
        func column(_ name: String) -> Int? { header.firstIndex(of: name) }

        guard let nameCol = column("node_name"),
              let usdCol = column("usd_node_name"),
              let groupCol = column("group"),
              let sideCol = column("side"),
              let viewCol = column("view"),
              let trisCol = column("tris"),
              let pathCol = column("usd_path") else {
            throw LoadError.malformed("CSV header missing expected columns")
        }

        var structures: [AtlasStructure] = []
        structures.reserveCapacity(rows.count - 1)
        for row in rows.dropFirst() {
            guard row.count > max(nameCol, usdCol, groupCol, sideCol, viewCol, trisCol) else { continue }
            let usdName = row[usdCol].trimmingCharacters(in: .whitespaces)
            guard !usdName.isEmpty else { continue }
            structures.append(
                AtlasStructure(
                    id: usdName,
                    nodeName: row[nameCol],
                    group: row[groupCol],
                    side: row[sideCol],
                    region: row[viewCol],
                    triangles: Int(row[trisCol]) ?? 0,
                    primPath: row.count > pathCol ? row[pathCol] : ""
                )
            )
        }
        guard !structures.isEmpty else { throw LoadError.malformed("no structures parsed") }

        // Mapping JSON: app content id -> atlas prims
        var contentForPrim: [String: String] = [:]
        let mapData = try Data(contentsOf: mapURL)
        if let map = try? JSONDecoder().decode(StructureMapFile.self, from: mapData) {
            for (contentID, mapping) in map.structures {
                for prim in mapping.usdNodes {
                    contentForPrim[prim] = contentID
                }
            }
        }

        let sorted = structures.sorted { lhs, rhs in
            if lhs.group != rhs.group { return groupRank(lhs.group) < groupRank(rhs.group) }
            return lhs.nodeName.localizedCaseInsensitiveCompare(rhs.nodeName) == .orderedAscending
        }

        let byID = Dictionary(uniqueKeysWithValues: sorted.map { ($0.id, $0) })
        var grouped: [(String, [AtlasStructure])] = []
        for (group, items) in Dictionary(grouping: sorted, by: { $0.group }) {
            grouped.append((group, items))
        }
        grouped.sort { groupRank($0.0) < groupRank($1.0) }

        return AtlasIndex(structures: sorted, byID: byID, appContentID: contentForPrim, groups: grouped)
    }

    private static func resourceURL(_ name: String, ext: String, bundle: Bundle) throws -> URL {
        if let url = bundle.url(forResource: name, withExtension: ext) { return url }
        if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "Brain") { return url }
        throw LoadError.missingResource("\(name).\(ext)")
    }

    static func groupRank(_ group: String) -> Int {
        switch group {
        case "Cerebral Cortex": return 0
        case "Cerebellum": return 1
        case "Brainstem": return 2
        case "Diencephalon": return 3
        case "Basal Ganglia": return 4
        case "Limbic System": return 5
        case "White Matter": return 6
        case "Ventricular System": return 7
        default: return 8
        }
    }
}

// MARK: - Descriptions

/// Short, scientifically careful copy. Specific structures get a sentence of their
/// own; everything else falls back to its anatomical system, so a tap always
/// produces something true rather than something invented.
enum StructureCopy {

    private static let specific: [String: String] = [
        "precentral gyrus": "Primary motor cortex. Its large pyramidal neurons send the commands that drive voluntary movement on the opposite side of the body.",
        "postcentral gyrus": "Primary somatosensory cortex, where touch, pressure, vibration and joint position from the body are first mapped.",
        "superior frontal gyrus": "Dorsolateral prefrontal territory involved in working memory, planning and the control of attention.",
        "middle frontal gyrus": "Part of the dorsolateral prefrontal cortex, central to holding goals in mind and switching between tasks.",
        "inferior temporal gyrus": "Higher-level visual recognition, including the shapes and identities of objects and faces.",
        "middle temporal gyrus": "Multimodal association cortex linking visual motion, language and semantic memory.",
        "superior temporal gyrus (lateral part)": "Auditory association cortex; the posterior part is classically linked to language comprehension.",
        "superior temporal sulcus": "A social-perception hub, responsive to voices, faces and biological motion.",
        "angular gyrus": "Cross-modal association cortex contributing to reading, number processing and semantic integration.",
        "supramarginal gyrus": "Parietal association cortex involved in phonological processing and the sense of the body in space.",
        "hippocampus": "A seahorse-shaped structure in the medial temporal lobe that binds experience into new long-term memories and supports spatial navigation.",
        "amygdaloid body": "Assigns emotional significance to sensory events and drives learned fear responses.",
        "thalamus": "The brain's relay hub: nearly all sensory and motor pathways pass through its nuclei before reaching the cortex.",
        "hypothalamus": "A small region that regulates temperature, hunger, thirst, circadian rhythm and hormone release through the pituitary.",
        "corpus callosum": "The largest white-matter commissure, carrying roughly 200 million axons between the hemispheres.",
        "lateral ventricle": "One of the fluid-filled chambers of the ventricular system, where cerebrospinal fluid is produced and circulated.",
        "third ventricle": "A midline CSF space between the thalami, continuous with the lateral ventricles and the cerebral aqueduct.",
        "fourth ventricle": "CSF space between the brainstem and cerebellum, draining into the subarachnoid space.",
        "caudate nucleus": "Part of the dorsal striatum, involved in action selection, habit learning and reward prediction.",
        "putamen": "A striatal nucleus central to motor control and reinforcement learning.",
        "globus pallidus": "A basal ganglia output stage that continuously brakes unwanted movement.",
        "cerebellar cortex": "The cerebellar surface, which compares intended with actual movement and fine-tunes timing and coordination.",
        "midbrain": "The upper brainstem segment housing the colliculi, substantia nigra and the cerebral aqueduct.",
        "pons": "The middle brainstem segment, a bridge between cortex, cerebellum and medulla.",
        "medulla oblongata": "The lowest brainstem segment, containing the centres for breathing, heart rate and blood pressure.",
        "optic chiasm": "Where the optic nerves partially cross, so each hemisphere receives the opposite visual field.",
        "insula": "Cortical territory folded inside the lateral fissure, linked to interoception, taste and emotional awareness.",
        "cingulate gyrus": "A limbic belt above the corpus callosum involved in emotion, pain processing and conflict monitoring.",
        "cuneus": "Occipital cortex on the upper bank of the calcarine sulcus, part of the primary visual pathway.",
        "lingual gyrus": "Occipital cortex on the lower bank of the calcarine sulcus, handling early visual processing.",
        "precuneus": "Medial parietal cortex associated with self-referential thought, mental imagery and episodic memory retrieval.",
        "corpus callosum (genu)": "The anterior curve of the corpus callosum, connecting the prefrontal cortices.",
    ]

    private static let groupFallback: [String: String] = [
        "Cerebral Cortex": "Part of the cerebral cortex — the folded sheet of grey matter that supports perception, movement, language and thought.",
        "Cerebellum": "Part of the cerebellum, which coordinates timing, balance and the smooth execution of movement.",
        "Brainstem": "Part of the brainstem, which carries every pathway between brain and body and houses vital autonomic centres.",
        "Diencephalon": "Part of the diencephalon, the relay and regulatory core around the third ventricle.",
        "Basal Ganglia": "Part of the basal ganglia, a set of deep nuclei that select and gate movement and habit.",
        "Limbic System": "Part of the limbic system, which links emotion, memory and motivation.",
        "White Matter": "White matter — bundles of myelinated axons that connect distant regions.",
        "Ventricular System": "Part of the ventricular system, the CSF-filled spaces that cushion the brain.",
    ]

    static func summary(for structure: AtlasStructure) -> String {
        let key = structure.displayName.lowercased()
        if let text = specific[key] { return text }

        // Try a prefix match, so "Cingulate gyrus and sulcus (Middle anterior part)"
        // still finds "cingulate gyrus".
        for (needle, text) in specific.sorted(by: { $0.key.count > $1.key.count }) where key.hasPrefix(needle) {
            return text
        }
        return groupFallback[structure.group]
            ?? "Part of the \(structure.group.lowercased()) of the human brain."
    }
}

// MARK: - Minimal CSV parser (quoted fields supported)

enum CSVParser {
    static func parse(_ raw: String) -> [[String]] {
        // Swift treats "\r\n" as one Character, so normalise line endings first.
        let text = raw
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        let chars = Array(text)
        var i = 0

        while i < chars.count {
            let c = chars[i]
            if inQuotes {
                if c == "\"" {
                    if i + 1 < chars.count && chars[i + 1] == "\"" {
                        field.append("\""); i += 2; continue
                    }
                    inQuotes = false; i += 1; continue
                }
                field.append(c); i += 1; continue
            }
            switch c {
            case "\"":
                inQuotes = true; i += 1
            case ",":
                row.append(field); field = ""; i += 1
            case "\n":
                row.append(field); field = ""; rows.append(row); row = []; i += 1
            case "\r":
                i += 1
            default:
                field.append(c); i += 1
            }
        }
        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }
        return rows
    }
}
