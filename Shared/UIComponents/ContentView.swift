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
  @StateObject var appState = AppState.shared
  
  var body: some View {
    ZStack {
      GeometryReader { proxy in
        content(proxy.size)
          .frame(width: proxy.size.width, height: proxy.size.height)
      }
    }
    .ignoresSafeArea()
    .onAppear {
      startCaptureSession()
    }
  }
  
  @ViewBuilder
  private func content(_ psize: CGSize) -> some View {
    FrameView()
    RiggedObject().opacity(0.1)
    StickFigure(size: psize).allowsHitTesting(false)
    InfoView()
  }
  
  private func startCaptureSession() {
    guard !__session.isRunning else {
      return
    }
    
    __queue.async {
      __session.startRunning()
      
      DispatchQueue.main.async {
        Camera.shared.configureSession()
        appState.nextGameState()
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
