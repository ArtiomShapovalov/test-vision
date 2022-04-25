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
    let pitch = (PI / 2) * ((0.19 - dist) / 0.19)
    
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
    
    let shoulderR = getLocation(for: .rightShoulder)
    let shoulderL = getLocation(for: .leftShoulder)
    let forearm = getLocation(for: .leftElbow)
    let hand = getLocation(for: .leftWrist)
    
    let distForearm = Math.distance2D(forearm, hand)
    let distUpperArm = Math.distance2D(shoulderL, forearm)
    
    var yawUpperArm = -atan(Math.tanOfLine(shoulderL, forearm))
    var yawForearm = atan(Math.tanOfLine(forearm, hand))
    
    if forearm.y < hand.y {
      yawForearm -= PI / 1.2
    } else {
      yawForearm -= PI / 2
      yawUpperArm -= PI / 8
    }
    
    var rollUpperArm = (PI / 2) * (distUpperArm / 0.1)
    
    let shoulderDiff = max(shoulderR.y - shoulderL.y, 0)
    let forearmHandDiff = (hand.y - forearm.y)
    
    if shoulderL.y > forearm.y + shoulderDiff + forearmHandDiff {
      rollUpperArm *= -1
    }
    
    var pitchForearm: CGFloat = 0
    
    if distForearm < 0.04 {
      pitchForearm = (PI / 2) * (distForearm / 0.08)
    }
    
//    let shoulderDiff = max(shoulderL.y - shoulderR.y, 0)
//    let forearmHandDiff = (hand.y - forearm.y)
//
//    if shoulderR.y < forearm.y + shoulderDiff + forearmHandDiff {
//      rollUpperArm *= -1
//    }
    
    jointsManager.append(item: yawUpperArm, to: &jointsManager.lHandYawUpperArm)
    jointsManager.append(item: yawForearm, to: &jointsManager.lHandYawForearm)
    jointsManager.append(item: rollUpperArm, to: &jointsManager.lHandRollShoulder)
    jointsManager.append(item: pitchForearm, to: &jointsManager.lHandPitchForearm)
    
    let maYawUpperArm = Math.calcMA(for: jointsManager.lHandYawUpperArm)
    let maYawForearm = Math.calcMA(for: jointsManager.lHandYawForearm)
    let maRollUpperArm = Math.calcMA(for: jointsManager.lHandRollShoulder)
    let maPitchForearm = Math.calcMA(for: jointsManager.lHandPitchForearm)
    
    let bones = rootNode.childNodes[5].childNodes[3].skinner?.bones
    
    if !useMA {
      bones?[6].eulerAngles = SCNVector3(0, yawUpperArm, rollUpperArm)
      bones?[7].eulerAngles = SCNVector3(pitchForearm, yawForearm, 0)
      return
    }
    
    if !maYawUpperArm.isNaN && !maRollUpperArm.isNaN {
      bones?[6].eulerAngles = SCNVector3(0, maYawUpperArm, maRollUpperArm)
    }
    
    if !maYawForearm.isNaN {
      bones?[7].eulerAngles = SCNVector3(maPitchForearm, maYawForearm, 0)
    }
  }
  
  private func updateRightHand() {
    guard let rootNode = self.rootNode else { return }
    
    let shoulderR = getLocation(for: .rightShoulder)
    let shoulderL = getLocation(for: .leftShoulder)
    let forearm = getLocation(for: .rightElbow)
    let hand = getLocation(for: .rightWrist)
  
    let distUpperArm = Math.distance2D(shoulderR, forearm)
    let distForearm = Math.distance2D(forearm, hand)
    
    var yawUpperArm = atan(Math.tanOfLine(shoulderR, forearm))
    var yawForearm = -atan(Math.tanOfLine(forearm, hand))
    
    if forearm.y < hand.y {
      yawForearm += PI / 1.2
    } else {
      yawForearm += PI / 2
      yawUpperArm += PI / 8
    }
    
    var rollUpperArm = (PI / 2) * (distUpperArm / 0.1)
    
    let shoulderDiff = max(shoulderL.y - shoulderR.y, 0)
    let forearmHandDiff = (hand.y - forearm.y)
    
    if shoulderR.y < forearm.y + shoulderDiff + forearmHandDiff {
      rollUpperArm *= -1
    }
    
    var pitchForearm: CGFloat = 0
    
    if distForearm < 0.04 {
      pitchForearm = (PI / 2) * (distForearm / 0.08)
    }
    
    print(distForearm)
    
//    print("locations:")
//    print(shoulderR.y, shoulderL.y)
//    print(forearm.y, hand.y)
//    print("res:", forearm.y + shoulderDiff + forearmHandDiff)
    
    jointsManager.append(item: yawUpperArm, to: &jointsManager.rHandYawUpperArm)
    jointsManager.append(item: yawForearm, to: &jointsManager.rHandYawForearm)
    jointsManager.append(item: rollUpperArm, to: &jointsManager.rHandRollShoulder)
    jointsManager.append(item: pitchForearm, to: &jointsManager.rHandPitchForearm)
    
    let maYawUpperArm = Math.calcMA(for: jointsManager.rHandYawUpperArm)
    let maYawForearm = Math.calcMA(for: jointsManager.rHandYawForearm)
    let maRollUpperArm = Math.calcMA(for: jointsManager.rHandRollShoulder)
    let maPitchForearm = Math.calcMA(for: jointsManager.rHandPitchForearm)
    
    let bones = rootNode.childNodes[5].childNodes[3].skinner?.bones
    
    if !useMA {
      bones?[29].eulerAngles = SCNVector3(0, yawUpperArm, rollUpperArm)
      bones?[30].eulerAngles = SCNVector3(pitchForearm, yawForearm, 0)
      return
    }
    
    if !maYawUpperArm.isNaN && !rollUpperArm.isNaN {
      bones?[29].eulerAngles = SCNVector3(0, maYawUpperArm, maRollUpperArm)
    }
    
    if !maYawForearm.isNaN {
      bones?[30].eulerAngles = SCNVector3(maPitchForearm, maYawForearm, 0)
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
