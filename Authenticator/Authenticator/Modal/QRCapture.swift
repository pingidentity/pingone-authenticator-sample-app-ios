//
//  QRCamera.swift
//  Authenticator
//
//  Created by Segev Sherry on 8/19/19.
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCaptureDelegate: class {

    func found(code: String)
    func failed(error: String)
}

class QRCapture: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer:   AVCaptureVideoPreviewLayer!
    weak var delegate:  QRCaptureDelegate?
    
    func stop(){
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func start(){
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    func addPreviewLayerTo(_ cameraView: UIView){
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            captureFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            captureFailed()
            return
        }
        
        DispatchQueue.main.async {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            self.previewLayer.frame = cameraView.layer.bounds
            self.previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(self.previewLayer)
            self.captureSession.startRunning()
        }
    }
    
    func captureFailed() {
        delegate?.failed(error: "Your device does not support scanning a code from an item. Please use a device with a camera.")
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        //dismiss(animated: true)
    }
    
    func found(code: String) {
        // Send code to delegate
        delegate?.found(code: code)
    }
    
    /*convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func addBehavior() {
        print("Add all the behavior here")
    }*/

}
