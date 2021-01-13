
//  LivenessCameraController.swift
//  mb_rbk
//
//  Created by Gulnaz on 12/24/19.
//  Copyright © 2019 Gulnaz. All rights reserved.
//

import AVFoundation
import UIKit
import CoreVideo
import MLKitVision
import MLKitFaceDetection

public protocol LivenessCameraDelegate: CameraControllerDelegate {
    /// called after all tests have been passed
    func handleRecognizedFace(_ face: UIImage)
    /// called after every test step
    func sendFacePhoto(_ face: UIImage)
}

public class LivenessCameraController: CameraController {
    var confirmStep: LivenessValidationType = .turnLeft
    private var faceFront: UIImage?
    
    private lazy var border = CAShapeLayer()
    
    @objc private func fireDelayTimer() {
        delayTimer?.invalidate()
    }
    private var livenessTimer: Timer?
    private var delayTimer: Timer?
    private let delay: TimeInterval = 5
    
    private lazy var actions: [LivenessValidationType] = []
    private var index: Int = 0
    private var frameCounter = 0
    open weak var delegate: LivenessCameraDelegate?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        actions = prepareActions()
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
            #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
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
       
        successView.cornered(radius: 40)
        successView.backgroundColor = RBKLivenessConfig.successColor
        imgView.tintColor = RBKLivenessConfig.imgTintColor
        successView.alpha = 0
    }
    
    private func prepareActions() -> [LivenessValidationType] {
        var actions: [LivenessValidationType] = []
        let headActions: [LivenessValidationType] = [.turnLeft, .turnRight]
        let faceActions: [LivenessValidationType] = [.smile, .blink]
        while actions.count < 2 {
            let headAction = headActions.getRandom()
            if !actions.contains(headAction) {
                actions.append(headAction)
            }
        }
        while actions.count < 4 {
            let faceAction = faceActions.getRandom()
            if !actions.contains(faceAction) {
                actions.append(faceAction)
            }
        }
        return actions
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension LivenessCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func convert(cmage:CIImage) -> UIImage
    {
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    public func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard frameCounter % 5 == 0 else {
            frameCounter += 1
            return
        }

        let visionImage = VisionImage(buffer: sampleBuffer)
        visionImage.orientation = .leftMirrored
        frameCounter += 1
        detectFacesOnDevice(in: visionImage, sampleBuffer: sampleBuffer)
    }
    
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )
        guard let context = CGContext(data: baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = context.makeImage() else {
            return nil
        }
        let orientation = UIUtilities.imageOrientation(
            fromDevicePosition: .front
        )
        let image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
       
    private func setDelay() {
        delayTimer?.invalidate()
        delayTimer = Timer.scheduledTimer(
            timeInterval: self.delay,
            target: self,
            selector: #selector(fireDelayTimer),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func detectFacesOnDevice(in image: VisionImage, sampleBuffer: CMSampleBuffer) {
        let options = FaceDetectorOptions()
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .all
        options.performanceMode = .fast
        let faceDetector = FaceDetector.faceDetector(options: options)

        var detectedFaces: [Face]?
        do {
            detectedFaces = try faceDetector.results(in: image)
        } catch let error {
            print("Failed to detect faces with error: \(error.localizedDescription).")
        }
    
        guard let faces = detectedFaces, !faces.isEmpty else {
            DispatchQueue.main.async {
                if self.livenessTimer?.isValid != true {
                    self.border.strokeColor = UIColor.red.cgColor
                    self.infoLabel.text = RBKLivenessConfig.faceNotFoundTitle
                }
            }
            return
        }
        
        guard faces.count == 1, let face = faces.first else {
            DispatchQueue.main.async {
                if self.livenessTimer?.isValid != true {
                    self.border.strokeColor = UIColor.red.cgColor
                    self.infoLabel.text = RBKLivenessConfig.toManyFaceErrorTitle
                }
                self.stopLivenessTimer()
            }
            return
        }
        
        guard let step = actions[safeIndex: index] else {
            if index == actions.count {
                handleSuccess(face: face, sampleBuffer: sampleBuffer)
            }
            return
        }
        
        confirmStep = step
        
        guard delayTimer == nil || delayTimer?.isValid == false else {
            return
        }
        
        // check for valid front head position
        self.getFaceImage(face, sampleBuffer: sampleBuffer)
        
        // check for current confirmStep
        DispatchQueue.main.async {
            self.infoLabel.text = self.confirmStep.title
            self.border.strokeColor = UIColor.green.cgColor
        }
        switch confirmStep {
        case .turnLeft, .leanLeft:
            let turnLeft1 = -1 * face.headEulerAngleY >= 40
            let leanLeft1 = face.headEulerAngleZ >= 25
            
            if self.livenessTimer?.isValid == true {
                let turnLeft2 = -1 * face.headEulerAngleY >= 10 && -1 * face.headEulerAngleY <= 20
                let leanLeft2 = face.headEulerAngleZ >= 10 && face.headEulerAngleZ <= 20
                if turnLeft2 || leanLeft2 {
                    self.livenessTimer?.invalidate()
                    self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
                }
            } else if turnLeft1 || leanLeft1 {
                self.startLivenessTimer()
            }
        case .turnRight, .leanRight:
            let turnRight1 = face.headEulerAngleY >= 40
            let leanRight1 = -1 * face.headEulerAngleZ >= 25
            
            if self.livenessTimer?.isValid == true {
                let turnRight2 = face.headEulerAngleY >= 10 && face.headEulerAngleY <= 20
                let leanRight2 = -1 * face.headEulerAngleZ >= 10 && -1 * face.headEulerAngleZ <= 20
                if turnRight2 || leanRight2 {
                    self.livenessTimer?.invalidate()
                    self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
                }
            } else if turnRight1 || leanRight1 {
                self.startLivenessTimer()
            }
                
//        case .leanLeft:
//            if self.livenessTimer?.isValid == true {
//                if face.headEulerAngleZ <= 20 && abs(face.headEulerAngleY) < 5 {
//                    self.livenessTimer?.invalidate()
//                    self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
//                }
//            } else if face.headEulerAngleZ > 20 && abs(face.headEulerAngleY) < 5 {
//                self.startLivenessTimer()
//            }
//        case .leanRight:
//            if self.livenessTimer?.isValid == true {
//                if  -1 * face.headEulerAngleZ <= 20 && abs(face.headEulerAngleY) < 5 {
//                    self.livenessTimer?.invalidate()
//                    self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
//                }
//            } else if -1 * face.headEulerAngleZ > 20 && abs(face.headEulerAngleY) < 5 {
//                self.startLivenessTimer()
//            } else {
//        }
        case .smile:
            if face.smilingProbability >= 0.9 {
                self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
            }
        case .blink:
            if face.leftEyeOpenProbability < 0.6 && face.rightEyeOpenProbability < 0.6 {
                self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
            }
        case .openMouth:
            if LivenessManager().checkOpenMouth(face) {
                self.handleSuccess(face: face, sampleBuffer: sampleBuffer)
            }
        }
    }
    
    private func startLivenessTimer() {
        DispatchQueue.main.async {
            self.livenessTimer = Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(self.stopLivenessTimer),
                userInfo: nil,
                repeats: false)
        }
    }
    @objc private func stopLivenessTimer() {
        self.livenessTimer?.invalidate()
    }
    
    enum LivenessValidationType {
        case smile
        case turnLeft
        case turnRight
        case leanLeft
        case leanRight
        case blink
        case openMouth
        
        var title: String {
            switch self {
            case .smile: return RBKLivenessConfig.smileTitle
            case .turnLeft: return RBKLivenessConfig.turnLeftTitle
            case .turnRight: return RBKLivenessConfig.turnRightTitle
            case .leanLeft: return RBKLivenessConfig.leanLeftTitle
            case .leanRight: return RBKLivenessConfig.leanRightTitle
            case .blink: return RBKLivenessConfig.blinkTitle
            case .openMouth: return RBKLivenessConfig.openMouthTitle
            }
        }
    }
    
    private func getFaceImage(_ face: Face, sampleBuffer: CMSampleBuffer) {
        let faceOrigin = face.frame.origin
        let faceSize = face.frame.size
        guard let targetFrame = previewLayer?.frame else {
            return
        }
        if faceOrigin.x > 0 && //faceOrigin.x > targetFrame.origin.x &&
            faceOrigin.y > 0 && //faceOrigin.y > targetFrame.origin.y &&
            (faceOrigin.x + faceSize.width) < (targetFrame.origin.x + targetFrame.size.width) &&
            (faceOrigin.y + faceSize.height) < (targetFrame.origin.y + targetFrame.size.height) {
            if abs(face.headEulerAngleZ) < 5 &&
                abs(face.headEulerAngleY) < 5 &&
                face.leftEyeOpenProbability > 0.9 &&
                face.rightEyeOpenProbability > 0.9 {
                DispatchQueue.main.async {
                    self.infoLabel.text = self.confirmStep.title
                    self.border.strokeColor = UIColor.green.cgColor
                }
                if self.faceFront == nil {
                    if let faceImage = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
                        self.faceFront = faceImage
                    }
                }
            } else if self.faceFront == nil {
                stopLivenessTimer()
                DispatchQueue.main.async {
                    self.infoLabel.text = RBKLivenessConfig.faceError1Title
                    self.border.strokeColor = UIColor.red.cgColor
                }
                return
            }
        } else {
            DispatchQueue.main.async {
                self.infoLabel.text = RBKLivenessConfig.faceError2Title
                self.border.strokeColor = UIColor.red.cgColor
            }
            return
        }
    }
    
    private func handleSuccess(face: Face,
                               sampleBuffer: CMSampleBuffer) {
        if let img = self.getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
            self.delegate?.sendFacePhoto(img)
        }
        DispatchQueue.main.async {
            self.infoLabel.text = RBKLivenessConfig.successTitle
            if self.index == self.actions.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if let img = self.getImageFromSampleBuffer(sampleBuffer: sampleBuffer) {
                        self.delegate?.handleRecognizedFace(img)
                    } else {
                        self.delegate?.handleError("Something wrong in liveness process")
                    }
                    self.delayTimer?.invalidate()
//                    self.handleCloseCamera()
                }
            } else {
                self.setDelay()
            }
            self.index += 1
        }
        self.updateSuccessView()
    }
    
    private func updateSuccessView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5,
                           animations: {
                self.successView.alpha = 1.0
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UIView.animate(withDuration: 0.5,
                                   animations: {
                        self.successView.alpha = 0.0
                    })
                }
            })
        }
    }
}
