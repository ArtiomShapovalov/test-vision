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
//        points: mapJoints(for: [.rightAnkle, .rightKnee, .rightHip,.root]),
        points: mapJoints3D(for: ["R_Ankle", "R_Knee", "R_Hip", "Pelvis"]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.yellow)
      // Left leg
      Stick(
//        points: mapJoints(for: [.leftAnkle, .leftKnee, .leftHip, .root]),
        points: mapJoints3D(for: ["L_Ankle", "L_Knee", "L_Hip", "Pelvis"]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.blue)
      // Right arm
      Stick(
//        points: mapJoints(for: [.rightWrist, .rightElbow, .rightShoulder, .neck]),
        points: mapJoints3D(for: ["R_Wrist", "R_Elbow", "R_Shoulder", "Thorax"]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.brown)
      // Left arm
      Stick(
//        points: mapJoints(for: [.leftWrist, .leftElbow, .leftShoulder, .neck]),
        points: mapJoints3D(for: ["L_Wrist", "L_Elbow", "L_Shoulder", "Thorax"]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.green)
      // Root to nose
      Stick(
//        points: mapJoints(for: [.root, .neck, .nose]),
        points: mapJoints3D(for: ["Pelvis", "Thorax", "Head"]),
        size: size
      )
      .stroke(lineWidth: 5.0)
      .fill(Color.red)
    }
  }
  
  // MARK: - Map joints to CGPoints
  
  private func mapJoints(for names: [VNHumanBodyPoseObservation.JointName]) -> [CGPoint] {
    return names.compactMap {
      guard let point = camOutput.bodyPoints[$0], point.confidence > 0.5 else {
        return nil
      }
      
      return CGPoint(
        x: 1 - point.location.x,
        y: point.location.y
      )
    }
  }
  
  private func mapJoints3D(for labels: [String]) -> [CGPoint] {
    return labels.compactMap { label in
      let jointIndex = PoseNet3D.shared.labels.firstIndex(of: label) ?? 0
      
      return CGPoint(
        x: getBodyPoint3D(jointIndex, 1),
        y: getBodyPoint3D(jointIndex, 2)
      )
    }
  }
  
  private func getBodyPoint3D(_ jointIndex: Int, _ i: Int) -> CGFloat {
    let j = camOutput.bodyPoints3D[0, jointIndex, i]
    
    return CGFloat(j / Float(64))
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
