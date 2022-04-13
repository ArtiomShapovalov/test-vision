//
//  ContentView.swift
//  Shared
//
//  Created by Artem Shapovalov on 05.04.2022.
//

import SwiftUI
import Vision
import AVFoundation
import Combine
import SoundAnalysis

var request: VNCoreMLRequest? = nil
var mdh = ModelDataHandler()

struct ContentView: View {
  private func setupVNRequest() {
    let configuration = MLModelConfiguration()
    
    do {
//      let model = try YOLOv3(configuration: configuration).model
//      let model = try YOLOv3FP16(configuration: configuration).model
//      let model = try YOLOv3Int8LUT(configuration: configuration).model
//      let model = try Mobilenet(configuration: configuration).model
//      let visionModel = try VNCoreMLModel(for: model)
//      print(visionModel)
//
//      request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
  //    request?.imageCropAndScaleOption = .centerCrop
    } catch {
      print(error)
    }
  }
  
  private func visionRequestDidComplete(request: VNRequest, error: Error?) {
    if let predictions = (
      request.results as? [VNRecognizedObjectObservation]
    ) {
      print(predictions[0])
//      let labels: [(id: String, confidence: VNConfidence)] = predictions.map { p in
//        let f = p.labels.first
//        return (id: f?.identifier ?? "", confidence: f?.confidence ?? 0.0)
//      }
//
//      print(ts, labels)
    }
  }
  
  private func startAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setCategory(.record, mode: .default)
    try? audioSession.setActive(true)
  }
  
  var body: some View {
    Text("Performing vision...")
      .padding()
      .onAppear {
        Task {
          let d = Date()

          SampleProcessor.shared.startProcessing()

          let elapsed = Date().timeIntervalSince(d)

          print("Finished in \(Int(elapsed.rounded())) seconds")
        }
      }
  }
}
