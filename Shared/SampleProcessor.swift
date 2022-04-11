//
//  SampleProcessor.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 11.04.2022.
//

import AVFoundation
import Combine
import SoundAnalysis

class SampleProcessor: NSObject {
  private var assetReader: AVAssetReader
  private let videoOutput: AVAssetReaderTrackOutput
  private let audioOutput: AVAssetReaderTrackOutput
  
  private var detectionCancellable: AnyCancellable? = nil
  private var analyzer: SNAudioStreamAnalyzer?
  private var retainedObservers: [SNResultsObserving]?
  var soundDetectionIsRunning: Bool = false
  private let analysisQueue = DispatchQueue(label: "com.anjlab.TestVision.AnalysisQueue")
  private var sampleNum = 0
  private let avFmt = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: 48_000,
    interleaved: false,
    channelLayout: AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Stereo)!
  )
  
  // MARK: - Configure AVAssetReader
  
  override init() {
    let url = Bundle.main.url(forResource: "test", withExtension: "mp4")!
    let asset = AVAsset(url: url)

    do {
      assetReader = try AVAssetReader(asset: asset)
    } catch {
      fatalError("Unable to read Asset: \(error).")
    }
    
    let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first
    let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first
    
    let videoReaderSettings: [String:Any] =  [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB
    ]
    
    videoOutput = AVAssetReaderTrackOutput(
      track: videoTrack!, outputSettings: videoReaderSettings
    )
    
    audioOutput = AVAssetReaderTrackOutput(
      track: audioTrack!, outputSettings: nil
    )
    
    assetReader.add(videoOutput)
    assetReader.add(audioOutput)
  }
  
  // MARK: - Start
  
  func startProcessing() {
    assetReader.startReading()
    
    let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()
    detectionCancellable =
    classificationSubject
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { _ in self.soundDetectionIsRunning = false },
        receiveValue: {
          print($0)
        }
      )
    
    do {
      let observer = ClassificationResultsSubject(subject: classificationSubject)
      let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
      request.windowDuration = CMTimeMakeWithSeconds(
        1.5, preferredTimescale: 48_000
      )
      request.overlapFactor = 0.9
      
      analyzer = SNAudioStreamAnalyzer(format: avFmt)
      try analyzer?.add(request, withObserver: observer)
      
      while assetReader.status == .reading {
  //      processVideo()
        try processAudio([(request, observer)])
        sampleNum += 1
      }
    } catch {
      classificationSubject.send(completion: .failure(error))
      stopProcessing()
    }
    
    stopProcessing()
  }
  
  // MARK: - Stop
  
  private func stopProcessing() {
    autoreleasepool {
      if let analyzer = analyzer {
        analyzer.removeAllRequests()
      }
      
      analyzer = nil
      retainedObservers = nil
      assetReader.cancelReading()
    }
  }
  
  // MARK: - Video processing
  
  private func processVideo() {
    if let sampleBuffer = videoOutput.copyNextSampleBuffer() {
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
  
  // MARK: - Audio processing
  
  private func processAudio(
    _ requestsAndObservers: [(SNRequest, SNResultsObserving)]
  ) throws {
    soundDetectionIsRunning = true
    let res = scheduleBuffer(audioOutput.copyNextSampleBuffer())
    if let buf = res.0, let fmt = res.1 {
      print("--------")
      print(buf, fmt)
      print(UInt32(self.sampleNum) * buf.frameLength)

//      retainedObservers = requestsAndObservers.map { $0.1 }

      self.analysisQueue.async {
        self.analyzer?.analyze(
          buf,
          atAudioFramePosition: AVAudioFramePosition(
            UInt32(self.sampleNum) * buf.frameLength
          )
        )
      }
    }
  }
  
  private func scheduleBuffer(_ sampleBuffer: CMSampleBuffer?) -> (AVAudioPCMBuffer?, AVAudioFormat?) {
    
    guard let sampleBuffer = sampleBuffer else {
      print("Buf is nil")
      stopProcessing()
      return (nil, nil)
    }

    let sDescr = CMSampleBufferGetFormatDescription(sampleBuffer)
    let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    ts = CMTimeGetSeconds(timestamp)
    print("timestamp ====> ", ts)
//    print(sDescr)
    
    let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)

    
//    let avFmt = AVAudioFormat(cmAudioFormatDescription: sDescr!)
    
    
//    var description = AudioStreamBasicDescription(mSampleRate: 48_000, mFormatID: kAudioFormatLinearPCM, mFormatFlags: 0, mBytesPerPacket: 1, mFramesPerPacket: 1, mBytesPerFrame: 1, mChannelsPerFrame: 1, mBitsPerChannel: 8, mReserved: 0)
//    let avFmt = AVAudioFormat(streamDescription: &description)

    let pcmBuffer = AVAudioPCMBuffer(
      pcmFormat: avFmt,
      frameCapacity: AVAudioFrameCount(UInt(numSamples))
    )
    
    pcmBuffer?.frameLength = AVAudioFrameCount(UInt(numSamples))
    
    if let mutableAudioBufferList = pcmBuffer?.mutableAudioBufferList {
      CMSampleBufferCopyPCMDataIntoAudioBufferList(
        sampleBuffer,
        at: 0,
        frameCount: Int32(numSamples),
        into: mutableAudioBufferList
      )
    }
    
    return (pcmBuffer, avFmt)
  }
}
