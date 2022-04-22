//
//  Math.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 21.04.2022.
//

import Foundation
import UIKit

let PI = CGFloat.pi

class Math {
  static func distance2D(_ v1: CGPoint, _ v2: CGPoint = .zero) -> CGFloat {
    return ((v1.x - v2.x) * (v1.x - v2.x) + (v1.y - v2.y) * (v1.y - v2.y)).squareRoot()
  }
  
  static func tanOfLine(_ v1: CGPoint, _ v2: CGPoint) -> CGFloat {
    let v3 = CGPoint(x: v1.x, y: v2.y)
    let k1 = Math.distance2D(v1, v3)
    let k2 = Math.distance2D(v2, v3)
    return k1 / k2
  }
  
  static func calcMA(for list: [CGFloat]) -> CGFloat {
    let summ = list
      .sorted()
      .dropFirst()
      .dropLast()
      .reduce(0, +)
    
    return summ / CGFloat(list.count)
  }
}

extension CGPoint {
  var sin: CGFloat {
    y / hypotenuse
  }
  
  var cos: CGFloat {
    x / hypotenuse
  }
  
  var hypotenuse: CGFloat {
    Math.distance2D(self)
  }
}
