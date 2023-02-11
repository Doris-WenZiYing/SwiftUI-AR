//
//  ARView.swift
//  SwiftUIAR
//
//  Created by Doris Trakarskys on 2023/2/11.
//

import SwiftUI
import ARKit
import RealityKit


struct ARViewContainer: UIViewRepresentable {
    
    //define an AR view
    var arView = ARView(frame: .zero)
    
    //create a initial view for ARView
    func makeUIView(context: Context) -> ARView {
        
        //if can't find the picture iin the resource, then go to else condition
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else {
            print("Can not find the file or image")
            return arView
        }
        
        let config = ARImageTrackingConfiguration()
        config.isAutoFocusEnabled = true
        config.trackingImages = referenceImages
        config.maximumNumberOfTrackedImages = 1
        
        arView.session.run(config)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        var parent: ARViewContainer
        
        //video looping
        var videolooper: AVPlayerLooper!
        let videoQueuePlayer = AVQueuePlayer()
        
        init(parent: ARViewContainer) {
            self.parent = parent
        }
        
        enum ImageName: String {
            case shadow = "shadow"
            case lamborghini = "lamborghini"
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            if let imageAnchor = anchors.first as? ARImageAnchor {
                guard let imageName = imageAnchor.referenceImage.name,
                      let imageCase = ImageName(rawValue: imageName)
                else { return }
                
                
                let entity = getEntity(for: imageCase, imageAnchor: imageAnchor)
                let anchor = AnchorEntity(anchor: imageAnchor)
                
                anchor.addChild(entity)
                parent.arView.scene.addAnchor(anchor)
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let imageAnchor = anchors.first as? ARImageAnchor else { return }
            
            // to see if the camera still focus on the photo
            if imageAnchor.isTracked {
                videoQueuePlayer.play()
            } else {
                videoQueuePlayer.pause()
                parent.arView.session.remove(anchor: imageAnchor)
            }
        }
        
        func getEntity(for name: ImageName, imageAnchor: ARImageAnchor) -> ModelEntity {
            createEntity(videoName: name.rawValue, imageAnchor: imageAnchor, type: "mp4")
        }
        
        func createEntity(videoName: String, imageAnchor: ARImageAnchor, type: String) -> ModelEntity {
            //get the relative video
            let path = Bundle.main.path(forResource: videoName, ofType: type)
            let videoURL = URL(fileURLWithPath: path!)
            let playerItem = AVPlayerItem(url: videoURL)
            videolooper = AVPlayerLooper(player: videoQueuePlayer, templateItem: playerItem)
            let videoMaterial = VideoMaterial(avPlayer: videoQueuePlayer)
            
            let width = Float(imageAnchor.referenceImage.physicalSize.width)
            let height = Float(imageAnchor.referenceImage.physicalSize.height)
            return ModelEntity(mesh: .generatePlane(width: width, depth: height), materials: [videoMaterial])
        }
    }
}
