//
//  RiggedObject.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 20.04.2022.
//

import SwiftUI
import SceneKit
import Vision

struct RiggedObject: View {
  @StateObject var camOutput = Camera.shared.output
  @State private var visionLocation = CGPoint.zero
  @State private var boneLocation = SCNVector3()
  private let characterScene = SCNScene(named: "testMale")
  
  var body: some View {
    ZStack {
      SceneView(
        scene: characterScene,
        options: [.autoenablesDefaultLighting, .allowsCameraControl]
      )
      VStack {
        Text("Vision: \(visionLocation.str)")
        Text("Bone: \(boneLocation.str)").padding()
      }
      .frame(width: 330, height: 100)
      .background(Color.blue.opacity(0.5))
      .offset(x: 0, y: 300)
    }
    .onChange(of: camOutput.bodyPoints) { _ in
      _updateBones()
    }
  }
  
  private func _updateBones() {
    guard let rootNode = characterScene?.rootNode else { return }
    
    let joint = camOutput.bodyPoints[VNHumanBodyPoseObservation.JointName.neck]
    guard let l = joint?.location else { return }
    
    visionLocation = l
    boneLocation = rootNode.childNodes[5].childNodes[3].skinner?.bones[3].position ?? SCNVector3() // SCNVector3(l.x, 0, 1 - l.y)
    
    // Neck bone in test 3d model
//    rootNode.childNodes[5].childNodes[3].skinner?.bones[3].position = boneLocation
  }
}

extension CGPoint {
  var str: String {
    String(format: "x: %.2f y: %.2f", x, y)
  }
}

extension SCNVector3 {
  var str: String {
    String(format: "x: %.2f z: %.2f", x, z)
  }
}
