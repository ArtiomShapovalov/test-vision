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
  @StateObject var jointsManager = JointsManager()
  private let characterScene = SCNScene(named: "testMale")
  private let rootNode: SCNNode?
  private let useMA: Bool
  
  init(useMA: Bool) {
    self.useMA = useMA
    rootNode = characterScene?.rootNode
  }
  
  var body: some View {
    ZStack {
      SceneView(
        scene: characterScene,
        options: [.autoenablesDefaultLighting, .allowsCameraControl]
      )
    }
    .onChange(of: camOutput.bodyPoints) { _ in
      updateSpine()
      updateLeftHand()
      updateRightHand()
    }
  }
  
  private func getLocation(for name: VNHumanBodyPoseObservation.JointName) -> CGPoint {
    camOutput.bodyPoints[name]?.location ?? .zero
  }
  
  private func updateSpine() {
    guard let rootNode = self.rootNode else { return }
    
    let neck = getLocation(for: .neck)
    let root = getLocation(for: .root)
    
    var yaw = atan(Math.tanOfLine(neck, root)) - PI / 2
    let dist = Math.distance2D(neck, root)
    let pitch = (PI / 2) * ((0.15 - dist) / 0.15)
    
    if neck.x < root.x {
      yaw *= -1
    }
    
    jointsManager.append(item: yaw, to: &jointsManager.spineYaw)
    jointsManager.append(item: pitch, to: &jointsManager.spinePitch)
    
    let maYaw = Math.calcMA(for: jointsManager.spineYaw)
    let maPitch = Math.calcMA(for: jointsManager.spinePitch)
    
    let bones = rootNode.childNodes[5].childNodes[3].skinner?.bones
    
    if maYaw.isNaN || maPitch.isNaN {
      return
    }
    
    if useMA {
      bones?[1].eulerAngles = SCNVector3(maPitch, maYaw, 0)
      return
    }
    
    bones?[1].eulerAngles = SCNVector3(pitch, yaw, 0)
  }
  
  private func updateLeftHand() {
    guard let rootNode = self.rootNode else { return }
    
    let shoulder = getLocation(for: .leftShoulder)
    let forearm = getLocation(for: .leftElbow)
    let hand = getLocation(for: .leftWrist)
    
    let yawUpperArm = -atan(Math.tanOfLine(shoulder, forearm))
    let yawForearm = atan(Math.tanOfLine(forearm, hand)) - PI / 2
    let distUpperArm = Math.distance2D(shoulder, forearm)
    
    var rollUpperArm = (PI / 2) * (distUpperArm / 0.08)
    
    if shoulder.y > forearm.y {
      rollUpperArm *= -1
    }
    
    jointsManager.append(item: yawUpperArm, to: &jointsManager.leftHandUpperArm)
    jointsManager.append(item: yawForearm, to: &jointsManager.leftHandForearm)
    jointsManager.append(item: rollUpperArm, to: &jointsManager.leftHandRoll)
    
    let maYawUpperArm = Math.calcMA(for: jointsManager.leftHandUpperArm)
    let maYawForearm = Math.calcMA(for: jointsManager.leftHandForearm)
    let maRollUpperArm = Math.calcMA(for: jointsManager.leftHandRoll)
    
    let bones = rootNode.childNodes[5].childNodes[3].skinner?.bones
    
    if !useMA {
      bones?[6].eulerAngles = SCNVector3(0, yawUpperArm, rollUpperArm)
      bones?[7].eulerAngles = SCNVector3(0, yawForearm, 0)
      return
    }
    
    if !maYawUpperArm.isNaN && !maRollUpperArm.isNaN {
      bones?[6].eulerAngles = SCNVector3(0, maYawUpperArm, maRollUpperArm)
    }
    
    if !maYawForearm.isNaN {
      bones?[7].eulerAngles = SCNVector3(0, maYawForearm, 0)
    }
  }
  
  private func updateRightHand() {
    guard let rootNode = self.rootNode else { return }
    
    let shoulder = getLocation(for: .rightShoulder)
    let forearm = getLocation(for: .rightElbow)
    let hand = getLocation(for: .rightWrist)
  
    let yawUpperArm = atan(Math.tanOfLine(shoulder, forearm))
    let yawForearm = -atan(Math.tanOfLine(forearm, hand)) + PI / 2
    let distUpperArm = Math.distance2D(shoulder, forearm)
    
    var rollUpperArm = (PI / 2) * (distUpperArm / 0.08)
    
    if shoulder.y < forearm.y {
      rollUpperArm *= -1
    }
    
    jointsManager.append(item: yawUpperArm, to: &jointsManager.rightHandUpperArm)
    jointsManager.append(item: yawForearm, to: &jointsManager.rightHandForearm)
    jointsManager.append(item: rollUpperArm, to: &jointsManager.rightHandRoll)
    
    let maYawUpperArm = Math.calcMA(for: jointsManager.rightHandUpperArm)
    let maYawForearm = Math.calcMA(for: jointsManager.rightHandForearm)
    let maRollUpperArm = Math.calcMA(for: jointsManager.rightHandRoll)
    
    let bones = rootNode.childNodes[5].childNodes[3].skinner?.bones
    
    if !useMA {
      bones?[29].eulerAngles = SCNVector3(0, yawUpperArm, rollUpperArm)
      bones?[30].eulerAngles = SCNVector3(0, yawForearm, 0)
      return
    }
    
    if !maYawUpperArm.isNaN && !rollUpperArm.isNaN {
      bones?[29].eulerAngles = SCNVector3(0, maYawUpperArm, maRollUpperArm)
    }
    
    if !maYawForearm.isNaN {
      bones?[30].eulerAngles = SCNVector3(0, maYawForearm, 0)
    }
  }
  
  private func updateLeftLeg() {
    guard let rootNode = self.rootNode else { return }
    
    let tigh = getLocation(for: .leftHip)
    let shin = getLocation(for: .leftKnee)
    let foot = getLocation(for: .leftAnkle)
    
    let angleTigh = atan(Math.tanOfLine(tigh, shin))
    let angleShin = atan(Math.tanOfLine(shin, foot))
    let distTigh = Math.distance2D(tigh, shin)
    
    let bones = rootNode.childNodes[5].childNodes[3].skinner?.bones
    print(bones ?? [], angleTigh, angleShin, distTigh)
  }
}
