//
//  SampleProcessor.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 11.04.2022.
//

import AVFoundation
import Combine
import SoundAnalysis

class SampleProcessor: NSObject, SNResultsObserving {
  static let shared = SampleProcessor()
  func request(_ request: SNRequest, didProduce result: SNResult) {
    print("AAAAAAAAAAAAAAAAA!!!!!!")
  }
  
  private var assetReader: AVAssetReader
  private let videoOutput: AVAssetReaderTrackOutput
  private let audioOutput: AVAssetReaderTrackOutput
  
  private var analyzer: SNAudioStreamAnalyzer?
  private var retainedObservers: [SNResultsObserving]?
  var soundDetectionIsRunning: Bool = false
  private let analysisQueue = DispatchQueue(
    label: "com.anjlab.TestVision.AnalysisQueue"
  )
  private var sampleNum = 0.0
  private var avFmt = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: 1024,
    interleaved: false,
    channelLayout: AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Mono)!
  )
  
  private let observer = AudioAnalysisObserver()
  
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
    
    do {
      // ClassificationResultsSubject(subject: subject)
      let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
//      request.windowDuration = CMTimeMakeWithSeconds(
//        1.5, preferredTimescale: 48_000
//      )
//      request.overlapFactor = 0.9

      print(avFmt)
      
      analyzer = SNAudioStreamAnalyzer(format: avFmt)
      try analyzer?.add(request, withObserver: observer)
      
      while assetReader.status == .reading {
        try processAudio()
        sampleNum += 1
      }
    } catch {
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
  
  private func processAudio() throws {
    soundDetectionIsRunning = true
    if let buf = scheduleBuffer(audioOutput.copyNextSampleBuffer()) {
      let when = Double(ts.value) + self.avFmt.sampleRate
      self.analysisQueue.async {
        print("buf ", when)
        self.analyzer?.analyze(
          buf, atAudioFramePosition: AVAudioFramePosition(when)
        )
      }
    }
  }
  
  private func scheduleBuffer(_ sampleBuffer: CMSampleBuffer?) -> AVAudioPCMBuffer? {
    
    guard let sampleBuffer = sampleBuffer else {
      print("Buf is nil")
      stopProcessing()
      return nil
    }

    let sDescr = CMSampleBufferGetFormatDescription(sampleBuffer)
    ts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
    ts = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
//    ts = CMTimeGetSeconds(timestamp)
//    print("timestamp ====> ", ts)
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
    
    return pcmBuffer
  }
}
