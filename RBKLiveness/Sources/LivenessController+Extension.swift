//
//  LivenessController+Extension.swift
//  RBKLiveness
//
//  Created by Gulnaz on 1/19/21.
//  Copyright © 2021 rbk. All rights reserved.
//

import UIKit
import AVFoundation
import MLKitVision
import MLKitFaceDetection

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension LivenessCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
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
