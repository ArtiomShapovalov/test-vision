//
//  ContentView.swift
//  Shared
//
//  Created by Artem Shapovalov on 05.04.2022.
//

import SwiftUI
import Vision
import AVFoundation

var request: VNCoreMLRequest? = nil
var ts: Float64 = 0

var mdh = ModelDataHandler()

struct ContentView: View {
  init() {
//    setupVNRequest()
    
    let url = Bundle.main.url(forResource: "test", withExtension: "mp4")!
    let asset = AVAsset(url: url)
    var assetReader: AVAssetReader

    do {
      assetReader = try AVAssetReader(asset: asset)
    } catch {
      fatalError("Unable to read Asset: \(error).")
    }
    
    let track = asset.tracks(withMediaType: AVMediaType.video).first
    
    let videoReaderSettings: [String:Any] =  [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
    ]
    
    let output = AVAssetReaderTrackOutput(
      track: track!, outputSettings: videoReaderSettings
    )
    
    assetReader.add(output)
    assetReader.startReading()
    
    let d = Date()
    
    while assetReader.status == .reading {
      if let sampleBuffer = output.copyNextSampleBuffer() {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        ts = CMTimeGetSeconds(timestamp)
//        if let buf = pixelBuffer, let req = request {
//          let handler = VNImageRequestHandler(cvPixelBuffer: buf)
//          try? handler.perform([req])
//        }
        
        if let buf = pixelBuffer {
          mdh?.runModel(onFrame: buf)
        }
      }
    }
    
    let elapsed = Date().timeIntervalSince(d)
    
    print("Finished in \(Int(elapsed.rounded())) seconds")
  }
  
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
  
  var body: some View {
    Text("Performing vision...").padding()
  }
}
