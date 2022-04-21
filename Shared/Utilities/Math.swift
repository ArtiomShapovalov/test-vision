//
//  Math.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 21.04.2022.
//

import Foundation
import UIKit

class Math {
  static func distance2D(_ v1: CGPoint, _ v2: CGPoint) -> CGFloat {
    return ((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y)).squareRoot()
  }
}
