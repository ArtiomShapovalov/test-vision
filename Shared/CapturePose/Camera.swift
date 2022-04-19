//
//  Camera.swift
//  TestVision (iOS)
//
//  Created by Artem Shapovalov on 18.04.2022.
//


import SwiftUI
import AVFoundation

extension AVCaptureDevice.Position {
  var str: String {
    switch self {
    case .back:        return "back"
    case .front:       return "front"
    case .unspecified: return "unspecified"
    default:           return "unknown"
    }
  }
}

let __session = AVCaptureSession()
let __queue   = DispatchQueue(label: "video.single.session.queue")

class Camera: NSObject {
  static let shared = Camera()
  
  @Published var chromakeyOn = false
  @Published var hidden      = false
  private var _viewLayer: AVCaptureVideoPreviewLayer?
  let videoOutput = AVCaptureVideoDataOutput()
  var deviceInput: AVCaptureDeviceInput?
  let preview    = AVCaptureVideoPreview()
  let output     = OutputCapturer()
  var deviceType = AVCaptureDevice.DeviceType.builtInWideAngleCamera
  var position   = AVCaptureDevice.Position.back
  
  var inputConnection:  AVCaptureConnection? = nil
  var outputConnection: AVCaptureConnection? = nil
  
  enum Keys: String, CodingKey {
    case chromakeyOn
    case hidden
  }
  
  init(
    deviceType: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
    position:   AVCaptureDevice.Position   = .back
  ) {
    self.deviceType = deviceType
    self.position   = position
    
    super.init()
  }
  
  class AVCaptureVideoPreview: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
      guard let layer = layer as? AVCaptureVideoPreviewLayer else {
        fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
      }
      
      layer.videoGravity = .resizeAspectFill
      return layer
    }
    
    override class var layerClass: AnyClass {
      return AVCaptureVideoPreviewLayer.self
    }
  }
  
  func configureSession() {
    preview.videoPreviewLayer.setSessionWithNoConnection(__session)
    _viewLayer = preview.videoPreviewLayer
    
    __session.beginConfiguration()
    
    defer {
      __session.commitConfiguration()
    }
    
    __session.automaticallyConfiguresCaptureDeviceForWideColor = false
    
    guard let camera = AVCaptureDevice.default(
      deviceType, for: .video, position: position
    ) else {
      print("no \(position.str) camera")
      return
    }
    
    do {
      deviceInput = try AVCaptureDeviceInput(device: camera)
      
      guard let input = deviceInput, __session.canAddInput(input) else {
        print("no \(position.str) camera device input")
        return
      }
      __session.addInputWithNoConnections(input)
    } catch {
      print("no \(position.str) camera device input: \(error)")
      return
    }
    
    guard let deviceInput = deviceInput,
          let videoPort = deviceInput.ports(
            for: .video,
            sourceDeviceType: camera.deviceType,
            sourceDevicePosition: camera.position
          ).first else {
      print("no \(position.str) camera input's video port")
      return
    }
    
    guard let layer = _viewLayer else { return }
    
    let connection = AVCaptureConnection(
      inputPort: videoPort, videoPreviewLayer: layer
    )
    
    guard __session.canAddConnection(connection) else {
      print("no a connection to the \(position.str) camera video preview layer")
      return
    }
    
    inputConnection = connection
    __session.addConnection(connection)
    
    guard __session.canAddOutput(videoOutput) else {
      print("No the \(position.str) camera video output")
      return
    }
    
//    let settings: [String: Any] = [
//        String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
//    ]
//
//    videoOutput.videoSettings = settings
//    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.setSampleBufferDelegate(output, queue: __queue)
    
    __session.addOutput(videoOutput)
    
    if let connection = videoOutput.connection(with: .video),
       connection.isVideoOrientationSupported {
      connection.videoOrientation = .portrait
      connection.isVideoMirrored = camera.position == .front
      
      // Inverse the landscape orientation to force the image in the upward
      // orientation.
      if connection.videoOrientation == .landscapeLeft {
        connection.videoOrientation = .landscapeRight
      } else if connection.videoOrientation == .landscapeRight {
        connection.videoOrientation = .landscapeLeft
      }
    }
    
//    __session.addOutputWithNoConnections(videoOutput)
    
//    let outputConn = AVCaptureConnection(
//      inputPorts: [videoPort], output: videoOutput
//    )
//    guard __session.canAddConnection(outputConn) else {
//      print("No connection to the \(position.str) video output")
//      return
//    }
//
//    outputConnection = outputConn
//    __session.addConnection(outputConn)
//
//    if StreamMeApp.Model.shared.streamLayout == .landscape {
//      outputConn.videoOrientation = .landscapeLeft
//    } else {
//      outputConn.videoOrientation = .portrait
//    }
  }
}
