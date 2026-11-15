import Foundation
import SwiftUI

// MARK: - Position
struct Position: Codable {
    let x: Double
    let y: Double
    let z: Double
}

// MARK: - Brain Structure Model
struct BrainStructure: Identifiable, Codable {
    let id: String
    let name: String
    let scientificName: String
    let category: BrainCategory
    let description: String
    let functions: [String]
    let realLifeImpact: [String]
    let improvementTips: [String]
    let color: String
    let position: Position
    let neurotransmitters: [String]
    let research: String
    let clinicalRelevance: String
}

// MARK: - Brain Categories
enum BrainCategory: String, Codable, CaseIterable {
    case memory = "Memory"
    case focus = "Focus"
    case emotion = "Emotions"
    case creativity = "Creativity"
    case learning = "Learning"
    case sleep = "Sleep"
    case stress = "Stress"
    case motivation = "Motivation"
    case language = "Language"
    case decision = "Decision Making"
    case motor = "Motor Control"
    case sensory = "Sensory"
    
    var icon: String {
        switch self {
        case .memory: return "brain.head.profile"
        case .focus: return "target"
        case .emotion: return "heart.fill"
        case .creativity: return "sparkles"
        case .learning: return "book.fill"
        case .sleep: return "moon.fill"
        case .stress: return "leaf.fill"
        case .motivation: return "flame.fill"
        case .language: return "text.bubble.fill"
        case .decision: return "scale.3d"
        case .motor: return "figure.run"
        case .sensory: return "hand.raised.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .memory: return BrainDesign.Colors.brainPurple
        case .focus: return BrainDesign.Colors.brainBlue
        case .emotion: return BrainDesign.Colors.brainPink
        case .creativity: return BrainDesign.Colors.accent
        case .learning: return BrainDesign.Colors.brainGreen
        case .sleep: return Color.indigo
        case .stress: return Color.teal
        case .motivation: return BrainDesign.Colors.brainOrange
        case .language: return Color.cyan
        case .decision: return Color(hex: "C9A37B")
        case .motor: return Color.orange
        case .sensory: return Color.pink
        }
    }
}

// MARK: - Brain Data
struct BrainData {
    static let structures: [BrainStructure] = [
        BrainStructure(
            id: "hippocampus",
            name: "Hippocampus",
            scientificName: "Hippocampus",
            category: .memory,
            description: "The hippocampus is a seahorse-shaped structure deep within your brain that plays a crucial role in forming new memories and connecting emotions to senses.",
            functions: [
                "Long-term memory formation",
                "Spatial navigation",
                "Learning new information",
                "Memory consolidation during sleep"
            ],
            realLifeImpact: [
                "Remembering names and faces",
                "Learning a new language",
                "Recalling past experiences",
                "Finding your way around"
            ],
            improvementTips: [
                "Get 7-9 hours of quality sleep",
                "Practice regular aerobic exercise",
                "Challenge your brain with puzzles",
                "Maintain social connections"
            ],
            color: "9B8DC9",
            position: Position(x: 0.3, y: -0.2, z: -0.3),
            neurotransmitters: ["Acetylcholine", "Glutamate"],
            research: "Harvard Medical School research shows the hippocampus can generate new neurons throughout life, a process called neurogenesis.",
            clinicalRelevance: "Damage to the hippocampus can result in anterograde amnesia—the inability to form new memories."
        ),
        
        BrainStructure(
            id: "prefrontal_cortex",
            name: "Prefrontal Cortex",
            scientificName: "Prefrontal Cortex",
            category: .decision,
            description: "The prefrontal cortex is the brain's executive headquarters, responsible for planning, decision-making, and moderating social behavior.",
            functions: [
                "Executive function",
                "Decision making",
                "Planning and foresight",
                "Impulse control"
            ],
            realLifeImpact: [
                "Making important life decisions",
                "Planning your day or career",
                "Controlling impulses",
                "Setting and achieving goals"
            ],
            improvementTips: [
                "Practice mindfulness meditation",
                "Break big tasks into smaller steps",
                "Get adequate sleep",
                "Reduce decision fatigue"
            ],
            color: "7BA3C9",
            position: Position(x: 0.0, y: 0.4, z: 0.2),
            neurotransmitters: ["Dopamine", "Serotonin"],
            research: "Stanford neuroscience studies show the prefrontal cortex continues developing until age 25.",
            clinicalRelevance: "Prefrontal cortex dysfunction is linked to ADHD, depression, and impaired decision-making."
        ),
        
        BrainStructure(
            id: "amygdala",
            name: "Amygdala",
            scientificName: "Amygdala",
            category: .emotion,
            description: "The amygdala is an almond-shaped cluster of nuclei that processes emotions, particularly fear and anxiety.",
            functions: [
                "Emotional processing",
                "Fear response",
                "Memory encoding",
                "Reward processing"
            ],
            realLifeImpact: [
                "Feeling anxious in new situations",
                "Forming emotional memories",
                "Social bonding and trust",
                "Fight or flight responses"
            ],
            improvementTips: [
                "Practice exposure therapy",
                "Try relaxation techniques",
                "Maintain consistent routines",
                "Build emotional awareness"
            ],
            color: "C98BB5",
            position: Position(x: 0.35, y: 0.1, z: -0.2),
            neurotransmitters: ["GABA", "Serotonin"],
            research: "NIH studies show the amygdala can shrink with chronic stress but can be strengthened through mindfulness.",
            clinicalRelevance: "An overactive amygdala is associated with anxiety disorders, PTSD, and phobias."
        ),
        
        BrainStructure(
            id: "cerebellum",
            name: "Cerebellum",
            scientificName: "Cerebellum",
            category: .motor,
            description: "The cerebellum, meaning 'little brain,' coordinates voluntary movements and maintains balance and posture.",
            functions: [
                "Motor coordination",
                "Balance and posture",
                "Motor learning",
                "Timing of movements"
            ],
            realLifeImpact: [
                "Playing sports or instruments",
                "Walking without falling",
                "Typing on a keyboard",
                "Catching a ball"
            ],
            improvementTips: [
                "Practice coordination exercises",
                "Try balance training",
                "Learn a new physical skill",
                "Maintain regular exercise"
            ],
            color: "7BC9A3",
            position: Position(x: 0.0, y: -0.4, z: -0.4),
            neurotransmitters: ["GABA", "Acetylcholine"],
            research: "Nature Neuroscience research reveals the cerebellum contains more than half of the brain's neurons.",
            clinicalRelevance: "Cerebellar damage can cause ataxia—a loss of coordination and muscle control."
        ),
        
        BrainStructure(
            id: "thalamus",
            name: "Thalamus",
            scientificName: "Thalamus",
            category: .sensory,
            description: "The thalamus acts as the brain's relay station, directing sensory information to the appropriate processing centers.",
            functions: [
                "Sensory signal routing",
                "Consciousness regulation",
                "Motor control assistance",
                "Sleep-wake cycle"
            ],
            realLifeImpact: [
                "Processing what you see and hear",
                "Maintaining alertness",
                "Coordinating movements",
                "Getting quality sleep"
            ],
            improvementTips: [
                "Maintain consistent sleep schedule",
                "Practice good sleep hygiene",
                "Engage in sensory-rich activities",
                "Reduce sensory overload"
            ],
            color: "C9A37B",
            position: Position(x: 0.0, y: 0.0, z: -0.1),
            neurotransmitters: ["Glutamate", "GABA"],
            research: "Studies show the thalamus acts as a filter, blocking unimportant sensory information.",
            clinicalRelevance: "Thalamic lesions can cause sensory deficits and altered states of consciousness."
        ),
        
        BrainStructure(
            id: "corpus_callosum",
            name: "Corpus Callosum",
            scientificName: "Corpus Callosum",
            category: .learning,
            description: "The corpus callosum is a thick band of nerve fibers connecting the brain's left and right hemispheres, enabling communication between them.",
            functions: [
                "Inter-hemispheric communication",
                "Integrating sensory information",
                "Coordinating bilateral movements",
                "Cognitive processing"
            ],
            realLifeImpact: [
                "Connecting creativity and logic",
                "Coordinating both hands",
                "Processing complex information",
                "Developing whole-brain thinking"
            ],
            improvementTips: [
                "Practice activities requiring both hands",
                "Learn music",
                "Do cross-lateral exercises",
                "Engage in creative problem-solving"
            ],
            color: "E8B4D9",
            position: Position(x: 0.0, y: 0.1, z: -0.2),
            neurotransmitters: ["GABA", "Glutamate"],
            research: "Stanford research shows corpus callosum integrity correlates with cognitive flexibility.",
            clinicalRelevance: "Severed corpus callosum (split-brain) reveals unique hemisphere specializations."
        ),
        
        BrainStructure(
            id: "hypothalamus",
            name: "Hypothalamus",
            scientificName: "Hypothalamus",
            category: .stress,
            description: "The hypothalamus links the nervous system to the endocrine system, regulating hormones, body temperature, hunger, and stress responses.",
            functions: [
                "Hormone regulation",
                "Body temperature control",
                "Hunger and thirst",
                "Stress response"
            ],
            realLifeImpact: [
                "Maintaining body homeostasis",
                "Managing hunger and appetite",
                "Regulating sleep cycles",
                "Controlling stress levels"
            ],
            improvementTips: [
                "Practice stress management",
                "Maintain consistent eating schedule",
                "Stay hydrated",
                "Get regular sleep"
            ],
            color: "7BA3C9",
            position: Position(x: 0.0, y: -0.1, z: -0.15),
            neurotransmitters: ["Dopamine", "Serotonin"],
            research: "NIH research links hypothalamus dysfunction to metabolic disorders and stress-related conditions.",
            clinicalRelevance: "The hypothalamus-pituitary-adrenal (HPA) axis is central to stress response disorders."
        ),
        
        BrainStructure(
            id: "temporal_lobe",
            name: "Temporal Lobe",
            scientificName: "Temporal Lobe",
            category: .language,
            description: "The temporal lobe processes auditory information and is essential for language comprehension and memory formation.",
            functions: [
                "Auditory processing",
                "Language comprehension",
                "Visual memory",
                "Emotional responses"
            ],
            realLifeImpact: [
                "Understanding spoken words",
                "Recognizing faces",
                "Learning new words",
                "Appreciating music"
            ],
            improvementTips: [
                "Practice active listening",
                "Learn a new language",
                "Listen to diverse music",
                "Play memory games"
            ],
            color: "9B8DC9",
            position: Position(x: 0.3, y: 0.0, z: 0.0),
            neurotransmitters: ["Glutamate", "GABA"],
            research: "Studies show bilingual brains have denser temporal lobe gray matter.",
            clinicalRelevance: "Temporal lobe epilepsy can cause auditory hallucinations and memory disturbances."
        ),
        
        BrainStructure(
            id: "occipital_lobe",
            name: "Occipital Lobe",
            scientificName: "Occipital Lobe",
            category: .sensory,
            description: "The occipital lobe at the back of the brain is the primary visual processing center, interpreting everything you see.",
            functions: [
                "Visual perception",
                "Color recognition",
                "Spatial awareness",
                "Motion detection"
            ],
            realLifeImpact: [
                "Recognizing objects and faces",
                "Reading and writing",
                "Driving safely",
                "Navigating spaces"
            ],
            improvementTips: [
                "Practice visual exercises",
                "Take breaks from screens",
                "Engage in visual arts",
                "Play eye-hand coordination games"
            ],
            color: "7BC9A3",
            position: Position(x: 0.0, y: 0.0, z: 0.4),
            neurotransmitters: ["Glutamate"],
            research: "Research shows the occipital lobe can reorganize after vision loss to process other senses.",
            clinicalRelevance: "Lesions to the occipital lobe can cause cortical blindness or visual agnosia."
        ),
        
        BrainStructure(
            id: "parietal_lobe",
            name: "Parietal Lobe",
            scientificName: "Parietal Lobe",
            category: .focus,
            description: "The parietal lobe processes sensory information about touch, temperature, pain, and spatial awareness.",
            functions: [
                "Sensory processing",
                "Spatial awareness",
                "Numerical reasoning",
                "Body awareness"
            ],
            realLifeImpact: [
                "Touching and feeling things",
                "Understanding directions",
                "Mathematical calculations",
                "Knowing where your body is in space"
            ],
            improvementTips: [
                "Practice spatial exercises",
                "Try puzzles and mazes",
                "Engage in physical activities",
                "Work on number games"
            ],
            color: "C9A37B",
            position: Position(x: -0.2, y: 0.2, z: 0.2),
            neurotransmitters: ["Glutamate", "GABA"],
            research: "Stanford neuroscience shows the parietal lobe is larger in taxi drivers.",
            clinicalRelevance: "Parietal lobe damage can cause neglect syndrome and spatial disorientation."
        ),
        
        BrainStructure(
            id: "broca_area",
            name: "Broca's Area",
            scientificName: "Broca's Area",
            category: .language,
            description: "Broca's area is responsible for speech production and language expression, translating thoughts into words.",
            functions: [
                "Speech production",
                "Grammar processing",
                "Articulation control",
                "Language expression"
            ],
            realLifeImpact: [
                "Speaking fluently",
                "Writing sentences",
                "Following complex instructions",
                "Expressing thoughts clearly"
            ],
            improvementTips: [
                "Practice public speaking",
                "Read aloud daily",
                "Write by hand",
                "Engage in debates"
            ],
            color: "C98BB5",
            position: Position(x: -0.25, y: 0.25, z: 0.1),
            neurotransmitters: ["GABA", "Glutamate"],
            research: "NIH studies show Broca's area activates during both speech and observation of speech.",
            clinicalRelevance: "Damage to Broca's area causes expressive aphasia—the inability to produce speech."
        ),
        
        BrainStructure(
            id: "wernicke_area",
            name: "Wernicke's Area",
            scientificName: "Wernicke's Area",
            category: .language,
            description: "Wernicke's area is crucial for language comprehension, enabling understanding of both spoken and written words.",
            functions: [
                "Language comprehension",
                "Meaning extraction",
                "Reading comprehension",
                "Semantic processing"
            ],
            realLifeImpact: [
                "Understanding conversations",
                "Reading comprehension",
                "Following instructions",
                "Learning new vocabulary"
            ],
            improvementTips: [
                "Practice active reading",
                "Listen to podcasts",
                "Learn new words daily",
                "Engage in discussions"
            ],
            color: "9B8DC9",
            position: Position(x: 0.25, y: 0.25, z: 0.1),
            neurotransmitters: ["Glutamate"],
            research: "Research shows Wernicke's area is functionally connected to auditory and visual association areas.",
            clinicalRelevance: "Damage causes receptive aphasia—speech that sounds normal but lacks meaning."
        )
    ]
    
    static func structure(for id: String) -> BrainStructure? {
        structures.first { $0.id == id }
    }
    
    static func structures(for category: BrainCategory) -> [BrainStructure] {
        structures.filter { $0.category == category }
    }
}
