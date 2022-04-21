//
//  InfoView.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 21.04.2022.
//

import SwiftUI
import Vision

struct InfoView: View {
  @StateObject private var camOutput = Camera.shared.output
  @StateObject private var appState = AppState.shared
  
  private func point(
    _ jointName: VNHumanBodyPoseObservation.JointName
  ) -> CGPoint? {
    return camOutput.bodyPoints[jointName]?.location
  }
  
  @ViewBuilder
  private func displayInfo() -> some View {
    VStack(alignment: .leading) {
      Text("State: \(appState.gameState.str)")
      if let v1 = point(.neck), let v2 = point(.root) {
        Text("Neck to Root distance: \(Math.distance2D(v1, v2))")
      } else {
        Text("No human body detected")
      }
    }
    .background(Color.blue.opacity(0.5).frame(width: 330, height: 100))
    .frame(width: 330, height: 100)
  }
  
  var body: some View {
    VStack {
      Spacer()
      displayInfo().padding(30)
    }
  }
}
