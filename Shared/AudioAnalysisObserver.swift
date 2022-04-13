//
//  AudioAnalysisObserver.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 11.04.2022.
//

import Foundation
import SoundAnalysis

class AudioAnalysisObserver: NSObject, SNResultsObserving {
  func requestDidComplete(_ request: SNRequest) {
    print("Processing completed!")
  }
  
  func request(_ request: SNRequest, didProduce result: SNResult) {
    guard let result = result as? SNClassificationResult,
          let bestClassification = result.classifications.first else  { return }
    let timeStart = result.timeRange.start.seconds
    
    print("Found \(bestClassification.identifier) at \(Int((bestClassification.confidence) * 100))% at \(timeStart)s")
  }
  
  func request(_ request: SNRequest, didFailWithError error: Error) {
    print("Failed with \(error)")
  }
}
