import SceneKit
import SwiftUI

struct ConfettiView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.isUserInteractionEnabled = false
        scnView.allowsCameraControl = false
        scnView.antialiasingMode = .multisampling2X

        let scene = SCNScene()
        scnView.scene = scene

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 15)
        scene.rootNode.addChildNode(cameraNode)

        let particles = SCNParticleSystem()
        particles.birthRate = 80
        particles.birthRateVariation = 20
        particles.particleLifeSpan = 5.0
        particles.particleLifeSpanVariation = 1.5
        particles.emitterShape = SCNBox(width: 14, height: 0.01, length: 0.01, chamferRadius: 0)
        particles.emittingDirection = SCNVector3(0, -1, 0)
        particles.spreadingAngle = 20
        particles.particleVelocity = 3.5
        particles.particleVelocityVariation = 1.5
        particles.acceleration = SCNVector3(0, -2.5, 0)
        particles.isAffectedByGravity = false
        particles.particleSize = 0.22
        particles.particleSizeVariation = 0.08
        particles.particleColor = UIColor(hue: 0, saturation: 0.9, brightness: 1.0, alpha: 1.0)
        particles.particleColorVariation = SCNVector4(1.0, 0.2, 0.1, 0)
        particles.particleAngularVelocity = 200
        particles.particleAngularVelocityVariation = 120
        particles.orientationMode = .free
        particles.sortingMode = .none
        particles.blendMode = .alpha
        particles.loops = true

        let emitterNode = SCNNode()
        emitterNode.position = SCNVector3(0, 9, 0)
        emitterNode.addParticleSystem(particles)
        scene.rootNode.addChildNode(emitterNode)

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

