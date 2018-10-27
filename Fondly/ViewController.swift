//
//  ViewController.swift
//  Fondly
//
//  Created by Hana Kim on 7/12/18.
//  Copyright © 2018 Hana Kim. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var photoTimer: Timer!
    var photoCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupCamera()

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        takePhoto(self)
    }
    
    func setupCamera() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            captureSession?.addOutput(capturePhotoOutput!)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            
        } catch {
            print(error)
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
        if( (AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized) && ( PHPhotoLibrary.authorizationStatus() == .authorized) ) {
            setupCamera()
            photoTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(capturePhotoBurst), userInfo: nil, repeats: true)
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    
                    PHPhotoLibrary.requestAuthorization({ (<#PHAuthorizationStatus#>) in
                        self.setupCamera()
                        self.photoTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.capturePhotoBurst), userInfo: nil, repeats: true)
                    })
                    
                    
                print("granded access to capture photos/videos, but not to add to library")
                
                
                } else {
                    print("not granted access to capture photos")
                }
            })
        }
       
    }
    
    @objc func capturePhotoBurst() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }

        if photoCount == 10 {
            photoTimer.invalidate()
            photoCount = 0
        } else
        {
            photoCount += 1
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.isAutoDualCameraFusionEnabled = true
            photoSettings.isPortraitEffectsMatteDeliveryEnabled = true
            photoSettings.isAutoRedEyeReductionEnabled = true
            photoSettings.flashMode = .off
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

//        print("took photo from view controller")
        
        let imageData = photo.fileDataRepresentation()
        let captureImage = UIImage.init(data: imageData!, scale: 1.0)
       
        if let image = captureImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
}


