//
//  Controls.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 22.04.2022.
//

import SwiftUI
import Vision

struct Controls: View {
  var changeMode: () -> () = {}
  var useMA: () -> () = {}
  
  var body: some View {
    VStack {
      HStack(spacing: 10) {
        Spacer()
        
        Button {
          useMA()
        } label: {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.5))
            .overlay(Text("MA").tint(.white))
        }
        .frame(width: 60, height: 60)
        
        Button {
          changeMode()
        } label: {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.5))
            .overlay(Image(systemName: "camera").tint(.white))
        }
        .frame(width: 60, height: 60)
      }
      .padding(.top, 50)
      .padding(.horizontal)
      Spacer()
    }
  }
}
