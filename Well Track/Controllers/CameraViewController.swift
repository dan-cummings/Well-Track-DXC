//
//  CameraViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraPosition {
    case front
    case back
}

class CameraViewController: UIViewController {

    var captureSession: AVCaptureSession?
    
    var cameraPosition: CameraPosition?
    
    var frontInput: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDevice?
    
    var backCamera: AVCaptureDevice?
    var backInput: AVCaptureDeviceInput?
    
    var captureOutput: AVCapturePhotoOutput?
    
    var photo: UIImage?
    
    @IBOutlet weak var previewLayer: UIView!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        prepareSession()
        prepareDevices()
        prepareInputOutput()
        startCapture()
    }

    @IBAction func takePhoto(_ sender: Any) {
        guard let photoOutput = captureOutput else {
            return
        }
        let photoSettings = AVCapturePhotoSettings()
        
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .auto
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func checkPermissions() {
        
    }
    
    func prepareSession() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func prepareDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = discoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
                cameraPosition = CameraPosition.back
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
    }
    
    func prepareInputOutput() {
        do {
            if cameraPosition == CameraPosition.back {
                let captureInput = try AVCaptureDeviceInput(device: backCamera!)
                captureSession?.addInput(captureInput)
            } else if cameraPosition == CameraPosition.front {
                let captureInput = try AVCaptureDeviceInput(device: frontCamera!)
                captureSession?.addInput(captureInput)
            }
            captureOutput = AVCapturePhotoOutput()
            captureOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureOutput?.isHighResolutionCaptureEnabled = true
            
            captureSession?.addOutput(captureOutput!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func startCapture() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        videoPreviewLayer?.frame = self.view.frame
        self.previewLayer.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession?.startRunning()
    }
    
    func previewPhoto() {
        let previewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "photopreview") as? PreviewViewController
        previewController!.image = self.photo
        self.navigationController?.pushViewController(previewController!, animated: true)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let dataBuffer = photo.fileDataRepresentation() else {return}
        
        self.photo = UIImage.init(data: dataBuffer)
        previewPhoto()
    }
}
