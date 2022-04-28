//
//  PoseNet3D.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 28.04.2022.
//

import Vision

class PoseNet3D: NSObject {
  static let shared = PoseNet3D()

  let model: VNCoreMLModel?
  let labels = [
    "Head_top", "Thorax", "R_Shoulder", "R_Elbow", "R_Wrist", "L_Shoulder",
    "L_Elbow", "L_Wrist", "R_Hip", "R_Knee", "R_Ankle", "L_Hip", "L_Knee",
    "L_Ankle", "Pelvis", "Spine", "Head", "R_Hand", "L_Hand", "R_Toe", "L_Toe"
  ]

  override init() {
    if let m = try? PoseNet(configuration: .init()).model {
      model = try? VNCoreMLModel(for: m)
    } else {
      model = nil
    }
    
    super.init()
  }
}
