# iBrain — demo video script

**File:** `iBrain_demo.mp4` · 1:51 · 1920×1080 · narration: Edge neural voice `en-US-AvaNeural` (edge-tts)

| # | Time | On screen | Narration |
|---|---|---|---|
| 1 | 0:00 | Brain rotating, "The brain, off the page" | Every brain you've ever seen in a classroom was flat. A picture, a few arrows, a memory test. iBrain turns it into something you can hold, rotate, and question. |
| 2 | 0:13 | Rotating atlas, "234 real structures" | This isn't an illustration. It's a real anatomical atlas. Two hundred and thirty-four separate structures, each one its own object, from the precentral gyrus to the pons. Drag to turn it. Pinch to move closer. Everything sits at the scale of a real human brain. |
| 3 | 0:32 | Tap → highlight + card, "Tap to explore" | Tap any region and it lights up, while the rest of the brain fades back. And you get an answer, not a label. What this structure is, which system it belongs to, and what it actually does. This is the superior frontal gyrus. Working memory, planning, attention. |
| 4 | 0:51 | Detail sheet, "Understand, not memorise" | Learn more opens the detail. Its functions, how it shows up in daily life, and why it matters clinically. This is the layer that turns anatomy into understanding. The thing a diagram can never give you. |
| 5 | 1:05 | Cortex hidden → internal cutaway, "Take it apart" | Because every structure is separate, you can take the brain apart. Hide a region to look inside, then bring everything back with a single tap. That view doesn't exist anywhere else. You're building it. |
| 6 | 1:19 | Learn + Library, "Learn & Library" | Learn collects the bigger questions. Memory, emotion, sleep, movement, and neuroplasticity. Library is where your saved regions and topics will live as the app grows. |
| 7 | 1:32 | End card, "Built for DSH Hacks" | iBrain is built with Swift, SwiftUI, and RealityKit, on top of an open anatomical atlas. The next step is an AI layer that meets you at the structure you're actually looking at. Built for DSH Hacks. |

## How it was made

- Screen footage: recorded from the app running in the iOS simulator (`xcrun simctl io recordVideo`), driven by debug launch flags so the demo shows real interactions rather than mock screenshots.
- Narration: `edge-tts` (Microsoft neural voice, online synthesis), one clip per scene, so each scene is cut to the length of its line.
- Assembly: ffmpeg — device screen scaled and rounded, composited on a paper-white canvas with the scene headline, then concatenated with the narration track.
- Captions: `iBrain_demo.srt` (7 cues, matches the narration word for word).
