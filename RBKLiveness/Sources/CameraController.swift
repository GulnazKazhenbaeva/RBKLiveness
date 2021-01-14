//
//  CameraController.swift
//  AVFoundation

import AVFoundation
import UIKit
import CoreVideo

public protocol CameraControllerDelegate: class {
    /// called on error
    func handleError(_ error: String)
}

public class CameraController: UIViewController {
    lazy var infoLabel = UILabel()
    lazy var successView = UIView()
    lazy var captureButton = UIButton()
    lazy var captureSession = AVCaptureSession()
    lazy var sessionQueue = DispatchQueue(label: "com.google.firebaseml.visiondetector.SessionQueue")
    
    open var cameraPosition: CameraPosition = .rear
    internal var hasCaptureButton = false
    
    internal var camera: AVCaptureDevice?
    internal var cameraInput: AVCaptureDeviceInput?
    internal var photoOutput: AVCapturePhotoOutput?
    
    internal var previewLayer: AVCaptureVideoPreviewLayer?
    
    internal var flashMode = AVCaptureDevice.FlashMode.off
    
    var maskFrame: CGRect?
    
    func setOutputs() {}
    func setTransparentPath(bounds: CGRect) {}
    func setInfoLabel() {}
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = RBKLivenessConfig.backgroundColor
        edgesForExtendedLayout = []
        
        DispatchQueue(label: "prepare").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
                
                DispatchQueue.main.async {
                    self.displayPreview(on: self.view)
                }
            } catch {
            }
        }
    }
    
    func addSubviews() {}
}

extension CameraController {
    func createCaptureSession() {
        self.captureSession = AVCaptureSession()
        self.captureSession.startRunning()
    }
        
    func configureCaptureDevices() throws {
        let session = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: cameraPosition == .front ? .front : .back
        )
        let cameras = session.devices.compactMap { $0 }
        guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
        
        for camera in cameras {
            if camera.position == .front {
                try camera.lockForConfiguration()
//                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
                self.camera = camera
            }
            
            if camera.position == .back {
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
                self.camera = camera
            }
        }
    }
                
    func configureDeviceInputs() throws {
//        sessionQueue.async {
            let cameraPosition: AVCaptureDevice.Position = self.cameraPosition == .front ? .front : .back
            do {
                self.captureSession.beginConfiguration()
                guard let device = self.captureDevice(forPosition: cameraPosition) else {
                    print("Failed to get capture device for camera position: \(cameraPosition)")
                    return
                }
                let currentInputs = self.captureSession.inputs
                for input in currentInputs {
                    self.captureSession.removeInput(input)
                }

                let input = try AVCaptureDeviceInput(device: device)
                guard self.captureSession.canAddInput(input) else {
                    print("Failed to add capture session input.")
                    return
                }
                self.captureSession.addInput(input)
                self.captureSession.commitConfiguration()
            } catch {
                print("Failed to create capture device input: \(error.localizedDescription)")
//                throw CameraControllerError.inputsAreInvalid
            }
//        }
    }
        
    func configurePhotoOutput() throws {
        self.captureSession.beginConfiguration()
        self.captureSession.sessionPreset = AVCaptureSession.Preset.medium
        
        self.setOutputs()
        self.captureSession.commitConfiguration()    }
        
    func displayPreview(on view: UIView) {
        guard captureSession.isRunning else {
            return
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        addInfoLabel(on: view)
        if hasCaptureButton {
            addCaptureButton(on: view)
        }
        
        setMask(on: view)
        addSubviews()
    }
    
    @objc func captureImage() {
        
    }
}

// MARK: AVCapturePhotoCaptureDelegate
extension CameraController {
    
    func cropToPreviewLayer(originalImage: UIImage, frame: CGRect) -> UIImage {
        guard let previewLayer = previewLayer,
            var cgImage = originalImage.cgImage else { return originalImage }
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: frame)
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width,
                              y: outputRect.origin.y * height,
                              width: outputRect.size.width * width,
                              height: outputRect.size.height * height)
        if let image = cgImage.cropping(to: cropRect) {
            cgImage = image
            let croppedUIImage = UIImage(cgImage: cgImage, scale: 0.0, orientation: originalImage.imageOrientation)
            let resized = croppedUIImage.resized(to: frame.size)
            return resized ?? croppedUIImage
        }
        return originalImage
    }
    
    func transformMatrix(image: UIImage) -> CGAffineTransform {
        let imageViewWidth = view.frame.size.width
        let imageViewHeight = view.frame.size.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        let imageViewAspectRatio = imageViewWidth / imageViewHeight
        let imageAspectRatio = imageWidth / imageHeight
        let scale = (imageViewAspectRatio > imageAspectRatio)
          ? imageViewHeight / imageHeight : imageViewWidth / imageWidth

        let scaledImageWidth = imageWidth * scale
        let scaledImageHeight = imageHeight * scale
        let xValue = (imageViewWidth - scaledImageWidth) / CGFloat(2.0)
        let yValue = (imageViewHeight - scaledImageHeight) / CGFloat(2.0)

        var transform = CGAffineTransform.identity.translatedBy(x: xValue, y: yValue)
        transform = transform.scaledBy(x: scale, y: scale)
        return transform
    }
    
    func handleCloseCamera() {
        self.captureSession.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
        self.infoLabel.removeFromSuperview()
        self.captureButton.removeFromSuperview()
//        self.delegate?.closeCamera()
    }
    
    func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

extension CameraController {
    func setMask(on view: UIView) {
        setTransparentPath(bounds: view.bounds)
    }
    
    func addCaptureButton(on view: UIView) {
        captureButton.backgroundColor = RBKLivenessConfig.buttonColor
        captureButton.tintColor = RBKLivenessConfig.buttonTitleColor
        captureButton.setImage(
            #imageLiteral(resourceName: "camera").withRenderingMode(.alwaysTemplate)
              .resized(to: RBKLivenessConfig.buttonSize),
            for: .normal)
        view.addSubview(captureButton)
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: captureButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: RBKLivenessConfig.buttonSize.height)
        let width = NSLayoutConstraint(item: captureButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: RBKLivenessConfig.buttonSize.width)
        let centerX = NSLayoutConstraint(item: captureButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let bottom: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            bottom = NSLayoutConstraint(item: captureButton, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide.bottomAnchor, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        } else {
            bottom = NSLayoutConstraint(item: captureButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        }
        view.addConstraints([height, width, centerX, bottom])
        
        captureButton.cornered(radius: RBKLivenessConfig.buttonSize.height / 2)
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    func addInfoLabel(on view: UIView) {
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = RBKLivenessConfig.infoTitleFont
        infoLabel.textColor = RBKLivenessConfig.infoTitleColor
        setInfoLabel()
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        let right = NSLayoutConstraint(item: infoLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 20)
        let left = NSLayoutConstraint(item: infoLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let top: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            top = NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20)
        } else {
            top = NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 20)
        }
        view.addConstraints([top, left, right])
    
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
