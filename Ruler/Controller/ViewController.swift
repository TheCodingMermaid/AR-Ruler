//
//  ViewController.swift
//  Ruler
//
//  Created by The Coding Mermaid on 24.12.21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    
    //MARK: - Outlet
    
    @IBOutlet var camera: UIBarButtonItem!
    @IBOutlet var sceneView: ARSCNView!
    
    //MARK: - Properties
    
   private var dotNodes = [SCNNode]()
   private var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        sceneView.debugOptions = [.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            clearScreen()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let raycastQuery = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                let results: [ARRaycastResult] = sceneView.session.raycast(raycastQuery)
                if let result = results.first {
                    addDot(at: result)
                }
            }
        }
    }
    
    func clearScreen() {
        textNode.removeFromParentNode()
        
        for dotNode in dotNodes {
            dotNode.removeFromParentNode()
        }
        dotNodes.removeAll()
    }
    
    
    //MARK: - Private Function Section
    
  private  func addDot(at result: ARRaycastResult) {
        let dotNode = SCNNode()
        dotNode.position = SCNVector3(result.worldTransform.columns.3.x,
                                      result.worldTransform.columns.3.y,
                                      result.worldTransform.columns.3.z)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        let dot = SCNSphere(radius: 0.002)
        dot.materials = [material]
        
        dotNode.geometry = dot
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
  private func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
      let a = end.position.x - start.position.x
      let b = end.position.y - start.position.y
      let c = end.position.z - start.position.z
      
      let distanceBetweenPoints = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
      let absoluteDistanceAsString = String(format: "%.2f", abs(distanceBetweenPoints) * 100)
      
      let distanceString = "Distance: " + absoluteDistanceAsString + "cm"
      
      updateText(text: distanceString, at: end.position)
      
  }
    
  private func updateText(text: String, at position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.purple
    
        
        
        textNode.geometry = textGeometry
        textNode.position = position
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}

