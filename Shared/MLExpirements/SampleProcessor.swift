//
//  SampleProcessor.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 11.04.2022.
//

import AVFoundation
import Combine
import SoundAnalysis

var mdh = VideoModelDataHandler()

class SampleProcessor: NSObject {
  static let shared = SampleProcessor()
  
  private var assetReader: AVAssetReader
  private let videoOutput: AVAssetReaderTrackOutput
  private let audioOutput: AVAssetReaderTrackOutput
  
  private var analyzer: SNAudioStreamAnalyzer?
  private var sampleNum = 0.0
  private var avFmt = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: 44_100,
    interleaved: true,
    channelLayout: AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_Stereo)!
  )
  
  private let observer = AudioAnalysisObserver()
  private var ts = CMTime()
  
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
    
    let audioReaderSettings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVSampleRateKey: 44_100,
      AVLinearPCMBitDepthKey: 32,
      AVLinearPCMIsNonInterleaved: false,
      AVLinearPCMIsFloatKey: true,
//      AVLinearPCMIsBigEndianKey: false
    ]
    
    audioOutput = AVAssetReaderTrackOutput(
      track: audioTrack!, outputSettings: audioReaderSettings
    )
    
    assetReader.add(videoOutput)
    assetReader.add(audioOutput)
  }
  
  // MARK: - Start
  
  func startProcessing() {
    assetReader.startReading()
    
    do {
      let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
      request.windowDuration = CMTimeMakeWithSeconds(
        1.5, preferredTimescale: 44_100
      )
      request.overlapFactor = 0.9

      print(avFmt)
      
      analyzer = SNAudioStreamAnalyzer(format: avFmt)
      try analyzer?.add(request, withObserver: observer)
      try processAudio()
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
    if let buf = scheduleBuffer(audioOutput.copyNextSampleBuffer()) {
      analyzeAudio(buf, sampleNum)
      try? processAudio()
    }
  }
  
  private func analyzeAudio(_ buf: AVAudioPCMBuffer, _ t: Double) {
    self.analyzer?.analyze(
      buf, atAudioFramePosition: AVAudioFramePosition(t)
    )
    sampleNum += Double(buf.frameLength)
  }
  
  private func scheduleBuffer(_ sampleBuffer: CMSampleBuffer?) -> AVAudioPCMBuffer? {
    guard let sampleBuffer = sampleBuffer else {
      print("Buf is nil")
      stopProcessing()
      return nil
    }
    
    let t = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
    
    guard ts.value <= t.value else {
      print("The end of samples")
      stopProcessing()
      return nil
    }
    
    ts = t
    
    let numSamples = CMSampleBufferGetNumSamples(sampleBuffer)

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
