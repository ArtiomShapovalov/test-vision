//
//  Camera+OutputCapturer.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 19.04.2022.
//

import Foundation
import AVFoundation
import Vision

typealias VNPoints = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]

extension Camera {
  class OutputCapturer: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @MainActor @Published var size: CGSize = .zero
    @MainActor @Published var bodyPoints: VNPoints  = [:]

    
    func captureOutput(
      _ output: AVCaptureOutput,
      didOutput sampleBuffer: CMSampleBuffer,
      from connection: AVCaptureConnection
    ) {
      let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
      let request = VNDetectHumanBodyPoseRequest { req, err in
        guard let observations =
                req.results as? [VNHumanBodyPoseObservation] else {
          return
        }
        
        observations.forEach { self.processObservation($0) }
      }
      
      do {
        try handler.perform([request])
      } catch {
        print("Unable to perform the request: \(error).")
      }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
      guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
        return
      }
      
      DispatchQueue.main.async {
        self.bodyPoints = recognizedPoints
      }
    }
  }
}
