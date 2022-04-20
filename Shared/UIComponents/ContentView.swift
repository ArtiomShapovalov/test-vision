//
//  ContentView.swift
//  Shared
//
//  Created by Artem Shapovalov on 05.04.2022.
//

import SwiftUI
import AVFoundation
import Combine
import SoundAnalysis

struct ContentView: View {
  
  var body: some View {
    ZStack {
      FrameView().frame(width: 720, height: 1280)
      
      RiggedObject().frame(width: 720, height: 1280).opacity(0.9)
      
      StickFigure(size: CGSize(width: 720, height: 1280)).allowsHitTesting(false)
    }
    .ignoresSafeArea()
    .onAppear {
      startCaptureSession()
    }
  }
  
  private func startCaptureSession() {
    guard !__session.isRunning else {
      return
    }
    
    __queue.async {
      __session.startRunning()
      
      DispatchQueue.main.async {
        Camera.shared.configureSession()
      }
    }
  }
  
  private func startAudioAnalysis() {
    Task {
      let d = Date()

      SampleProcessor.shared.startProcessing()

      let elapsed = Date().timeIntervalSince(d)

      print("Finished in \(Int(elapsed.rounded())) seconds")
    }
  }
}
