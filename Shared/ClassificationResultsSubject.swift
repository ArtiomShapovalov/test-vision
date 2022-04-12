//
//  ClassificationResultsSubject.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 11.04.2022.
//

import Foundation
import SoundAnalysis
import Combine

/// An observer that forwards Sound Analysis results to a combine subject.
///
/// Sound Analysis emits classification outcomes to observer objects. When classification completes, an
/// observer receives termination messages that indicate the reason. A subscriber receives a stream of
/// results and a termination message with an error, if necessary.

class ClassificationResultsSubject: NSObject, SNResultsObserving {
  private let subject: PassthroughSubject<SNClassificationResult, Error>
  
  init(subject: PassthroughSubject<SNClassificationResult, Error>) {
    self.subject = subject
  }
  
  func request(_ request: SNRequest,
               didFailWithError error: Error) {
    subject.send(completion: .failure(error))
  }
  
  func requestDidComplete(_ request: SNRequest) {
    subject.send(completion: .finished)
  }
  
  func request(_ request: SNRequest,
               didProduce result: SNResult) {
    print(result)
    if let result = result as? SNClassificationResult {
      subject.send(result)
    }
  }
}

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
