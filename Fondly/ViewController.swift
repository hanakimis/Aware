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
        
        setupAndTakePicture()
        
        // allows us to get photos when app is in foreground again
        NotificationCenter.default.addObserver(self, selector: #selector(setupAndTakePicture), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    

    
    @objc func setupAndTakePicture() {
        setupCamera()
        takePhoto()
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
    
    @IBAction func buttonPress(_ sender: Any) {
        takePhoto()
    }
    
    
    func takePhoto() {
        photoTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(capturePhotoBurst), userInfo: nil, repeats: true)
        
        if (AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized) {
            print("entered authorized status")
        } else {
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
//                if granted {
//                } else {
//                }
//            })
        }
    }
    
    @objc func capturePhotoBurst() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }

        if photoCount == 10 {
            photoTimer.invalidate()
            photoCount = 0
        } else {
            photoCount += 1
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.isHighResolutionPhotoEnabled = true
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
        
        let imageData = photo.fileDataRepresentation()
        let captureImage = UIImage.init(data: imageData!, scale: 1.0)
        
        
        if let image = captureImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
}


