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
    
    var cameraPosition: CameraPosition = .back
    
    var micInput: AVCaptureDeviceInput?
    var mic: AVCaptureDevice?
    
    var frontInput: AVCaptureDeviceInput?
    var frontCamera: AVCaptureDevice?
    
    var backCamera: AVCaptureDevice?
    var backInput: AVCaptureDeviceInput?
    
    var capturePhotoOutput: AVCapturePhotoOutput?
    var captureVideoOutput: AVCaptureMovieFileOutput?
    
    var videoCap: Bool = false
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var previewLayer: UIView!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermissions()
    }
    
    override func viewWillLayoutSubviews() {
        videoPreviewLayer?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
        videoPreviewLayer?.connection?.videoOrientation = currentVideoOrientation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.captureSession?.startRunning()
        }
    }

    @IBAction func takePhoto(_ sender: Any) {
        if videoCap {
            guard let videoOutput = captureVideoOutput else {
                print("Error")
                return
            }
            if videoOutput.isRecording {
                UIView.animate(withDuration: 0.2, animations: {
                    self.captureButton.layer.cornerRadius = 25
                })
                videoOutput.stopRecording()
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.captureButton.layer.cornerRadius = 5
                    })
                let tempUrl = tempURL()
            
                let connection = videoOutput.connection(with: AVMediaType.video)
                if connection!.isVideoOrientationSupported {
                    connection!.videoOrientation = currentVideoOrientation()
                }
                if connection!.isVideoStabilizationSupported {
                    connection!.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                }
                
                if cameraPosition == .back {
                    if backCamera!.isSmoothAutoFocusSupported {
                        do {
                            try backCamera?.lockForConfiguration()
                            backCamera?.isSmoothAutoFocusEnabled = false
                            backCamera?.unlockForConfiguration()
                        } catch {
                            print(error.localizedDescription)
                        }
                    } else {
                        do {
                            try frontCamera?.lockForConfiguration()
                            frontCamera?.isSmoothAutoFocusEnabled = false
                            frontCamera?.unlockForConfiguration()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                videoOutput.startRecording(to: tempUrl!, recordingDelegate: self)
            }
        } else {
            guard let photoOutput = capturePhotoOutput else {
                return
            }
            let photoSettings = AVCapturePhotoSettings()
            
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.isAutoStillImageStabilizationEnabled = true
            if cameraPosition == .front {
                photoSettings.flashMode = .off
            } else {
                photoSettings.flashMode = .auto
            }
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func checkPermissions() {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
            
        case .denied:
            self.displaySettingsAlert()
            break
        case .authorized:
            self.prepareSession()
            break
        case .restricted: break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.prepareSession()
                    }
                } else {
                    print("Permissions not granted");
                }
                })
        }
    }
    
    func prepareSession() {
        captureSession = AVCaptureSession()
        if self.videoCap {
            captureSession?.sessionPreset = AVCaptureSession.Preset.high
        } else {
            captureSession?.sessionPreset = AVCaptureSession.Preset.photo
        }
        prepareDevices()
    }
    
    func prepareDevices() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = discoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        if let _ = audioDevice {
            mic = audioDevice
        }
        prepareInputOutput()
    }
    
    func prepareInputOutput() {
        do {
            if !videoCap {
                capturePhotoOutput = AVCapturePhotoOutput()
                capturePhotoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
                capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                captureSession?.addOutput(capturePhotoOutput!)
            } else {
                captureButton.backgroundColor = .red
                micInput = try AVCaptureDeviceInput(device: mic!)
                captureSession?.addInput(micInput!)
                captureVideoOutput = AVCaptureMovieFileOutput()
                captureSession?.addOutput(captureVideoOutput!)
            }
            
            if cameraPosition == CameraPosition.back {
                backInput = try AVCaptureDeviceInput(device: backCamera!)
                captureSession?.addInput(backInput!)
            } else if cameraPosition == CameraPosition.front {
                frontInput = try AVCaptureDeviceInput(device: frontCamera!)
                captureSession?.addInput(frontInput!)
            }
        } catch {
            print(error.localizedDescription)
        }
        startCapture()
    }
    
    func startCapture() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = currentVideoOrientation()
        videoPreviewLayer?.frame = self.view.frame
        self.previewLayer.layer.insertSublayer(videoPreviewLayer!, at: 0)
        
        captureSession?.startRunning()
    }
    
    @IBAction func cameraFlip(_ sender: Any) {
        if captureSession!.isRunning {
            captureSession?.beginConfiguration()
        }
        if cameraPosition == .front {
            cameraPosition = .back
        } else {
            cameraPosition = .front
        }
        guard let currentInput = captureSession?.inputs.last as? AVCaptureDeviceInput else {
            return
        }

        captureSession?.removeInput(currentInput)
        
        do {
            if cameraPosition == .front {
                frontInput = try AVCaptureDeviceInput(device: frontCamera!)
                captureSession?.addInput(frontInput!)
            } else {
                backInput = try AVCaptureDeviceInput(device: backCamera!)
                captureSession?.addInput(backInput!)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        captureSession?.commitConfiguration()
        
    }
    
    func previewMedia(media: Any?) {
        let previewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "photopreview") as! PreviewViewController
        if let photo = media as? UIImage {
            previewController.image = photo
        } else if let videoURL = media as? URL {
            previewController.videoPreview = true
            previewController.videoURL = videoURL
        }
        previewController.hideButton = false
        self.navigationController?.pushViewController(previewController, animated: true)
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
        let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func displaySettingsAlert() {
        let avc = UIAlertController(title: "Camera Permission Required",
                                    message: "Well Track needs permissions to the camera and microphone to add those features to Log creation. You can change permissions by going to the settings app and going to Privacy -> Camera", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {
            action in
            UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        avc.addAction(settingsAction)
        avc.addAction(cancelAction)
        
        self.present(avc, animated: true, completion: nil)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let dataBuffer = photo.fileDataRepresentation() else {return}
        previewMedia(media: UIImage.init(data: dataBuffer))
    }
}
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            return
        }
        previewMedia(media: outputFileURL)
    }
}
