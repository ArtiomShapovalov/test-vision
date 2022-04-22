//
//  GameState.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 15.04.2022.
//

import Foundation

enum GameState: Int {
  case inactive
  case detectingPerson
  case detectedPerson
  
  var str: String {
    switch self {
    case .inactive:        return "Inactive"
    case .detectingPerson: return "Detecting person"
    case .detectedPerson:  return "Person is detected"
    }
  }
}
