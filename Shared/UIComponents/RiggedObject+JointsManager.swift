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
    
    @Published var leftHandUpperArm: [CGFloat] = []
    @Published var leftHandForearm:  [CGFloat] = []
    @Published var leftHandRoll:     [CGFloat] = []
    
    @Published var rightHandUpperArm: [CGFloat] = []
    @Published var rightHandForearm:  [CGFloat] = []
    @Published var rightHandRoll:     [CGFloat] = []
    
    
    let maxListCopacity = 12
    
    init() {
      
    }
    
    func append(item: CGFloat, to list: inout [CGFloat]) {
      if list.count >= maxListCopacity {
        list.remove(at: 0)
      }
      list.append(item)
    }
  }
}
