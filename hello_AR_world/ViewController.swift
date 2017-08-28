//
//  ViewController.swift
//  hello_AR_world
//
//  Created by doug on 8/15/17.
//  Copyright © 2017 doug. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let vaseNode = SCNNode()
    let cupNode = SCNNode()
    let chairNode = SCNNode()
    let lampNode = SCNNode()
    var node = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(pinch:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panRecognized(pan:)))

        self.view.addGestureRecognizer(pinchGesture)
        self.view.addGestureRecognizer(panGesture)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let vaseButton = UIButton(frame: CGRect(x: 50, y: 100, width: 100, height: 50))
        vaseButton.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.8)
        vaseButton.setTitle("Set Vase", for: .normal)
        vaseButton.addTarget(self, action: #selector(setVaseNode), for: .touchUpInside)
        
        let cupButton = UIButton(frame: CGRect(x: 50, y: 200, width: 100, height: 50))
        cupButton.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.8)
        cupButton.setTitle("Set Cup", for: .normal)
        cupButton.addTarget(self, action: #selector(setCupNode), for: .touchUpInside)
        
        let chairButton = UIButton(frame: CGRect(x: 50, y: 300, width: 100, height: 50))
        chairButton.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.8)
        chairButton.setTitle("Set Chair", for: .normal)
        chairButton.addTarget(self, action: #selector(setChairNode), for: .touchUpInside)
        
        let lampButton = UIButton(frame: CGRect(x: 50, y: 400, width: 100, height: 50))
        lampButton.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.8)
        lampButton.setTitle("Set Lamp", for: .normal)
        lampButton.addTarget(self, action: #selector(setLampNode), for: .touchUpInside)
        
        self.view.addSubview(vaseButton)
        self.view.addSubview(cupButton)
        self.view.addSubview(chairButton)
        self.view.addSubview(lampButton)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let standardConfiguration: ARWorldTrackingConfiguration = {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            return configuration
        }()
        
        // Run the view's session
        sceneView.session.run(standardConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        /* Looking at the location where the user touched the screen */
        let result = sceneView.hitTest(sender.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}

        /* transforms the result into a matrix_float 4x4 so the SCN Node can read the data */
        let hitTransform = hitResult.worldTransform

        /* Print the coordinates captured */
        print("x: ", hitTransform[3].x, "\ny: ", hitTransform[3].y, "\nz: ", hitTransform[3].z)

        /* Look at Add Geometry Class in Controller Group */
        switch node {
        case vaseNode:
            addObject(position: hitTransform, sceneView: sceneView, node: vaseNode, objectPath: "art.scnassets/vase/vase.scn")
        case cupNode:
            addObject(position: hitTransform, sceneView: sceneView, node: cupNode, objectPath: "art.scnassets/cup/cup.scn")
        case chairNode:
            addObject(position: hitTransform, sceneView: sceneView, node: chairNode, objectPath: "art.scnassets/chair/chair.scn")
        case lampNode:
            addObject(position: hitTransform, sceneView: sceneView, node: lampNode, objectPath: "art.scnassets/lamp/lamp.scn")
        default:
            print("No Node Found")
        }
    }
    
    func addObject(position: matrix_float4x4, sceneView: ARSCNView, node: SCNNode, objectPath: String){
        
        node.position = SCNVector3(position[3].x, position[3].y, position[3].z)
        
        // Create a new scene
        guard let virtualObjectScene = SCNScene(named: objectPath)
            else {
                print("Unable to Generate" + objectPath)
                return
        }
        
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        
        node.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        node.runAction(SCNAction.scale(by: pinch.scale, duration: 0.1))
    }
    
    @objc func panRecognized(pan: UIPanGestureRecognizer) {

        let xPan = pan.velocity(in: sceneView).x/10000
        /*
         y pan is a not tuned for user expereience 
        let yPan = pan.velocity(in: sceneView).y/10000
         */
        
        node.runAction(SCNAction.rotateBy(x: 0, y: xPan, z: 0, duration: 0.1))
    }
    
    @objc func setVaseNode(sender: UIButton!) {
        node = vaseNode
    }
    
    @objc func setCupNode(sender: UIButton!) {
        node = cupNode
    }
    
    @objc func setChairNode(sender: UIButton!) {
        node = chairNode
    }
    
    @objc func setLampNode(sender: UIButton!) {
        node = lampNode
    }
    
}



