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
      Text("State: \(appState.gameState.str)").frame(width: 300, alignment: .leading)
      if
        appState.gameState == .detectedPerson,
        let v1 = point(.neck),
        let v2 = point(.root),
        let d = Math.distance2D(v1, v2)
      {
        if d < 0.105 {
          Text("Come closer").foregroundColor(.red)
        } else if d > 0.165 {
          Text("Step back").foregroundColor(.red)
        } else {
          Text("Good!").foregroundColor(.green)
        }
      } else {
        Text("No human body detected")
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.blue.opacity(0.3))
        .frame(width: 330, height: 100)
    )
    .frame(width: 330, height: 100)
  }
  
  var body: some View {
    VStack {
      Spacer()
      displayInfo().padding(30)
    }
  }
}
