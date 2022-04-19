//
//  FrameView.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 19.04.2022.
//

import SwiftUI

// MARK: - Display camera preview

struct FrameView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    return Camera.shared.preview
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
  }
}
