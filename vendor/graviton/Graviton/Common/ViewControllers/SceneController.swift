//
//  SceneController.swift
//  Graviton
//
//  Created by Sihao Lu on 1/8/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import MathUtil
import SceneKit
import UIKit

class SceneController: UIViewController, SCNSceneRendererDelegate {
    var cameraModifier: CameraResponsive?

    lazy var pan: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))

    lazy var doubleTap: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(recenter(sender:)))
        gr.numberOfTapsRequired = 2
        return gr
    }()

    lazy var zoom: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))

    lazy var rotationGR: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotate(sender:)))

    var cameraController: CameraController?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCameraController()
        view.addGestureRecognizer(doubleTap)
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(zoom)
        view.addGestureRecognizer(rotationGR)
    }

    @objc func recenter(sender _: UIGestureRecognizer) {
        cameraController?.slideVelocity = CGPoint()
        cameraController?.referenceSlideVelocity = CGPoint()
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        cameraModifier?.resetCamera()
        SCNTransaction.commit()
    }

    func loadCameraController() {
        cameraController = CameraController()
    }

    @objc func zoom(sender: UIPinchGestureRecognizer) {
        guard let legacyCameraController = cameraController else {
            return
        }
        switch sender.state {
        case .began:
            legacyCameraController.previousScale = cameraModifier?.scale
            sender.scale = CGFloat((cameraModifier?.scale ?? 1) / (legacyCameraController.previousScale ?? 1))
        case .changed:
            cameraModifier?.scale = legacyCameraController.previousScale! * Double(sender.scale)
            sender.scale = CGFloat((cameraModifier?.scale ?? 1) / (legacyCameraController.previousScale ?? 1))
        case .ended:
            cameraModifier?.scale = legacyCameraController.previousScale! * Double(sender.scale)
            sender.scale = CGFloat((cameraModifier?.scale ?? 1) / (legacyCameraController.previousScale ?? 1))
            legacyCameraController.previousScale = nil
        default:
            break
        }
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let legacyCameraController = cameraController else {
            return
        }
        legacyCameraController.slideVelocity = sender.velocity(in: view).cap(to: legacyCameraController.viewSlideVelocityCap)
        legacyCameraController.referenceSlideVelocity = legacyCameraController.slideVelocity
        legacyCameraController.slidingStopTimestamp = nil
    }

    @objc func rotate(sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .began:
            cameraController?.previousRotation = cameraModifier?.cameraNode.rotation
        case .ended:
            cameraController?.previousRotation = nil
        default:
            break
        }
    }

    // MARK: - Scene Renderer Delegate

    func renderer(_: SCNSceneRenderer, didRenderScene _: SCNScene, atTime time: TimeInterval) {
        cameraController?.handleCameraPan(atTime: time)
        cameraController?.rotation = rotationGR.rotation
        cameraController?.handleCameraRotation(atTime: time)
    }
}

extension CGPoint {
    /// Cap the value not to exceed an absolute magnitude
    ///
    /// - Parameter percentage: The value cap.
    /// - Returns: The capped value.
    func cap(to percentage: CGFloat) -> CGPoint {
        return CGPoint(x: x > 0 ? min(x, percentage) : max(x, -percentage), y: y > 0 ? min(y, percentage) : max(y, -percentage))
    }
}
