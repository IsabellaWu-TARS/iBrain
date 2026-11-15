import SwiftUI
import RealityKit

/// Bridges the RealityKit `ARView` (non-AR camera, RealityKit renderer) into SwiftUI
/// and owns the gesture recognisers for rotate / zoom / tap.
struct BrainViewer: UIViewRepresentable {
    @ObservedObject var controller: BrainSceneController

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.backgroundColor = UIColor(Theme.background)
        view.isMultipleTouchEnabled = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        controller.attach(arView: view)
        context.coordinator.installGestures(on: view)
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(controller: controller) }

    @MainActor
    final class Coordinator: NSObject {
        private let controller: BrainSceneController
        private var lastPanTranslation: CGPoint = .zero

        init(controller: BrainSceneController) {
            self.controller = controller
        }

        func installGestures(on view: ARView) {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            pan.maximumNumberOfTouches = 1
            view.addGestureRecognizer(pan)

            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            view.addGestureRecognizer(pinch)

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.addGestureRecognizer(tap)

            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)
            tap.require(toFail: doubleTap)
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let view = gesture.view else { return }
            let translation = gesture.translation(in: view)
            switch gesture.state {
            case .began:
                lastPanTranslation = .zero
            case .changed:
                let dx = translation.x - lastPanTranslation.x
                let dy = translation.y - lastPanTranslation.y
                controller.rotate(deltaX: dx, deltaY: dy)
                lastPanTranslation = translation
            default:
                lastPanTranslation = .zero
            }
        }

        @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                controller.beginPinch()
            case .changed:
                controller.updatePinch(scale: gesture.scale)
            default:
                break
            }
        }

        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view else { return }
            controller.handleTap(at: gesture.location(in: view))
        }

        @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            controller.resetCamera()
        }
    }
}
