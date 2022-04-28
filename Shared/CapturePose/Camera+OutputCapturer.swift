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
    @MainActor @Published var bodyPoints3D = MultiArray<Float>(shape: [4, 21, 3])
    
    func captureOutput(
      _ output: AVCaptureOutput,
      didOutput sampleBuffer: CMSampleBuffer,
      from connection: AVCaptureConnection
    ) {
      detect3D(sampleBuffer)
    }
    
    private func detect2D(_ buf: CMSampleBuffer) {
      let handler = VNImageRequestHandler(cmSampleBuffer: buf)
      let request = VNDetectHumanBodyPoseRequest { req, err in
        guard
          let observations = req.results as? [VNHumanBodyPoseObservation],
          !observations.isEmpty
        else {
          DispatchQueue.main.async {
            if self.bodyPoints != [:] {
              AppState.shared.gameState = .detectingPerson
            }
          }
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
    
    private func detect3D(_ buf: CMSampleBuffer) {
      guard let m = PoseNet3D.shared.model else { return }
      
      let request = VNCoreMLRequest(
        model: m,
        completionHandler: { request, error in
          guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                let topResult = results.first else {
            print(error as Any)
            return
          }
          
          guard let v = topResult.featureValue.multiArrayValue else {
            return
          }
          
          var multiArray = MultiArray<Float>(v)
          
          DispatchQueue.main.async {
            multiArray.id = self.bodyPoints3D.id + 1
            self.bodyPoints3D = multiArray
          }
        }
      )
      
      request.imageCropAndScaleOption = .centerCrop

      let handler = VNImageRequestHandler(cmSampleBuffer: buf, orientation: .up)
      DispatchQueue.global(qos: .userInteractive).async {
        do {
          try handler.perform([request])
        } catch {
          print(error)
        }
      }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
      guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
        return
      }
      
      DispatchQueue.main.async {
        AppState.shared.gameState = .detectedPerson
        self.bodyPoints = recognizedPoints
      }
    }
  }
}
