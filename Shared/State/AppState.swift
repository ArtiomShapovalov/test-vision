//
//  AppState.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 15.04.2022.
//

import Foundation

class AppState: ObservableObject {
  static var shared = AppState()
  
  @Published var gameState: GameState = .inactive
  @Published var gameMode: GameMode = .model3d
  
  init() {
    
  }
  
  func nextGameState() {
    switch gameState {
    case .inactive:
      gameState = .detectingPerson
    case .detectingPerson:
      gameState = .detectedPerson
    case .detectedPerson:
      break
    }
  }
  
  func nextGameMode() {
    switch gameMode {
    case .stickFigure:
      gameMode = .model3d
    case .model3d:
      gameMode = .stickFigure
    }
  }
}
