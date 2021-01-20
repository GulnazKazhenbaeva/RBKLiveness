//
//  LivenessController.swift
//  RBKLiveness
//

import AVFoundation
import UIKit
import CoreVideo

public protocol LivenessCameraDelegate: CameraControllerDelegate {
    /// called after all tests have been passed
    func handleRecognizedFace(_ face: UIImage)
    /// called after every test step
    func sendFacePhoto(_ face: UIImage)
}

public class LivenessCameraController: CameraController {
    var confirmStep: LivenessValidationType = .turnLeft
    internal var faceFront: UIImage?
    
    internal lazy var border = CAShapeLayer()
    
    @objc internal func fireDelayTimer() {
        delayTimer?.invalidate()
    }
    internal var livenessTimer: Timer?
    internal var delayTimer: Timer?
    internal let delay: TimeInterval = 5
    
    internal lazy var actions: [LivenessValidationType] = []
    internal var index: Int = 0
    internal var frameCounter = 0
    open weak var delegate: LivenessCameraDelegate?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        actions = LivenessValidationType.prepareActions()
        index = 0
        frameCounter = 0
    }
   
    override func setOutputs() {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
          (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
        ]
        let outputQueue = DispatchQueue(label: "com.google.firebaseml.visiondetector.VideoDataOutputQueue")
        output.setSampleBufferDelegate(self, queue: outputQueue)
        guard self.captureSession.canAddOutput(output) else {
          print("Failed to add capture session output.")
          return
        }
        self.captureSession.addOutput(output)
    }
    
    override func setTransparentPath(bounds: CGRect) {
        let width = bounds.size.width * 0.8
        let height = (bounds.size.height - captureButton.frame.height) * 0.7
        let x = (bounds.size.width - width) / 2
        let y = (bounds.size.height - height - captureButton.frame.height) / 2
        let holeRect = CGRect(x: x, y: y, width: width, height: height)
        self.maskFrame = holeRect
        
        let lineWidth: CGFloat = 5
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let ovalLine = CAShapeLayer()
        let path = UIBezierPath(ovalIn: rect)
        ovalLine.path = path.cgPath
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = ovalLine.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = lineWidth
        borderLayer.frame = view.bounds
        self.border = borderLayer
        previewLayer?.addSublayer(borderLayer)
        previewLayer?.frame = holeRect
        previewLayer?.mask = ovalLine
        
        guard let previewLayer = previewLayer else { return }
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.addSublayer(previewLayer)
    }
    
    override func setInfoLabel() {
        infoLabel.text = RBKLivenessConfig.faceError2Title
    }
    
    override func addSubviews() {
        let imgView = UIImageView(image:
            UIImage(named: "checked.png")?.withRenderingMode(.alwaysTemplate)
        )
        successView.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: imgView, attribute: .top, relatedBy: .equal, toItem: successView, attribute: .top, multiplier: 1, constant: 20)
        let left = NSLayoutConstraint(item: imgView, attribute: .left, relatedBy: .equal, toItem: successView, attribute: .left, multiplier: 1, constant: 20)
        let right = NSLayoutConstraint(item: imgView, attribute: .right, relatedBy: .equal, toItem: successView, attribute: .right, multiplier: 1, constant: -20)
        let bottom = NSLayoutConstraint(item: imgView, attribute: .bottom, relatedBy: .equal, toItem: successView, attribute: .bottom, multiplier: 1, constant: -20)
        successView.addConstraints([top, left, right, bottom])
        
        self.view.addSubview(successView)
        successView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: successView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: RBKLivenessConfig.successViewSize.height)
        let width = NSLayoutConstraint(item: successView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: RBKLivenessConfig.successViewSize.width)
        let centerX = NSLayoutConstraint(item: successView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: successView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        view.addConstraints([height, width, centerX, centerY])
       
        successView.clipsToBounds = true
        successView.layer.cornerRadius = 40
        
        successView.backgroundColor = RBKLivenessConfig.successColor
        imgView.tintColor = RBKLivenessConfig.imgTintColor
        successView.alpha = 0
    }
}
