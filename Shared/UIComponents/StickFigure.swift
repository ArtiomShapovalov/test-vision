//
//  StickFigure.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 19.04.2022.
//

import SwiftUI
import Vision

// MARK: - Display sticks over human body

struct StickFigure: View {
  @StateObject var camOutput = Camera.shared.output
  var size: CGSize
  var body: some View {
    ZStack {
      // Right leg
      Stick(
        points: mapJoints(for: [.rightAnkle, .rightKnee, .rightHip,.root]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.green)
      // Left leg
      Stick(
        points: mapJoints(for: [.leftAnkle, .leftKnee, .leftHip, .root]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.green)
      // Right arm
      Stick(
        points: mapJoints(for: [.rightWrist, .rightElbow, .rightShoulder, .neck]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.green)
      // Left arm
      Stick(
        points: mapJoints(for: [.leftWrist, .leftElbow, .leftShoulder, .neck]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.green)
      // Root to nose
      Stick(points: mapJoints(for: [.root, .neck, .nose]), size: size)
      .stroke(lineWidth: 5.0)
      .fill(Color.green)
    }
  }
  
  // MARK: - Map joints to CGPoints
  
  private func mapJoints(for names: [VNHumanBodyPoseObservation.JointName]) -> [CGPoint] {
    return names.compactMap {
      guard let point = camOutput.bodyPoints[$0], point.confidence > 0 else {
        return nil
      }
      
      return CGPoint(
        x: 1 - point.location.x,
        y: point.location.y
      )
    }
  }
  
  // MARK: - Stick shape
  
  struct Stick: Shape {
    var points: [CGPoint]
    var size: CGSize
    func path(in rect: CGRect) -> Path {
      var path = Path()
      
      if points.isEmpty {
        return path
      }
      
      path.move(to: points[0])
      for point in points {
        path.addLine(to: point)
      }
      return path.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
        .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
  }
}
