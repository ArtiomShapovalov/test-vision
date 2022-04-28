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
  @State private var gameMode = GameMode.stickFigure
  @State private var useMA = true
  private let testViewSize = CGSize(width: 1280, height: 720)
  
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
    if gameMode == .stickFigure {
      CameraView()
      StickFigure(size: psize)
    } else {
      CameraView()
      RiggedObject(useMA: useMA).opacity(0.9)
      StickFigure(size: psize).allowsHitTesting(false).opacity(0.3)
    }
    InfoView()
    Controls(changeMode: {
      if gameMode == .model3d {
        gameMode = .stickFigure
      } else {
        gameMode = .model3d
      }
    }, useMA: {
      useMA.toggle()
    })
  }
  
  private func startCaptureSession() {
    guard !__session.isRunning else {
      return
    }
    
    __queue.async {
      __session.startRunning()
      
      DispatchQueue.main.async {
        Camera.shared.configureSession()
        AppState.shared.nextGameState()
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
