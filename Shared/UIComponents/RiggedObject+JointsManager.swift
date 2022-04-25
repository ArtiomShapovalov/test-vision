//
//  RiggedObject+JointsManager.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 22.04.2022.
//

import SwiftUI

extension RiggedObject {
  
  class JointsManager: ObservableObject {
    
    @Published var spinePitch: [CGFloat] = []
    @Published var spineYaw:   [CGFloat] = []
    
    @Published var lHandPitchForearm: [CGFloat] = []
    @Published var lHandYawUpperArm:  [CGFloat] = []
    @Published var lHandYawForearm:   [CGFloat] = []
    @Published var lHandRollShoulder: [CGFloat] = []
    
    @Published var rHandPitchForearm: [CGFloat] = []
    @Published var rHandYawUpperArm:  [CGFloat] = []
    @Published var rHandYawForearm:   [CGFloat] = []
    @Published var rHandRollShoulder: [CGFloat] = []
    
    // MARK: Accuracy of MA
    // The amount of data used for the calculation of the MA.
    // The higher the accuracy, the smoother the animation and the slower the
    // reaction of the model.
    let maAccuracy = 12
    
    init() {
      
    }
    
    func append(item: CGFloat, to list: inout [CGFloat]) {
      if list.count >= maAccuracy {
        list.remove(at: 0)
      }
      list.append(item)
    }
  }
}
