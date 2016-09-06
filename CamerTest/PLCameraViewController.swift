//
//  PLCameraViewController.swift
//  CamerTest
//
//  Created by Yu chengJhuo on 9/4/16.
//  Copyright © 2016 Yu-cheng Jhuo. All rights reserved.

import UIKit
import AVFoundation


public typealias TakeCameraCompletion = (UIImage?) -> Void

class PLCameraViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    

    @IBOutlet weak var PLView: UIView!
    var onCompletion: TakeCameraCompletion?
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput!
    var prevLayer: AVCaptureVideoPreviewLayer?
    var widthAndHeight : CGFloat = 500
    
    init(WidthAndHeight: CGFloat , completion: TakeCameraCompletion) {
        super.init(nibName: nil, bundle: nil)
        self.widthAndHeight = WidthAndHeight
        onCompletion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        prevLayer?.frame.size = PLView.frame.size
    }
    
    
    func createSession() {
        session = AVCaptureSession()
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            input = nil
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if session!.canAddInput(input) {
            session!.addInput(input)
        }
        
        let outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        imageOutput = AVCaptureStillImageOutput()
        imageOutput.outputSettings = outputSettings
        
        session!.addOutput(imageOutput)
        
        prevLayer = AVCaptureVideoPreviewLayer(session: session)
        prevLayer?.frame.size = PLView.frame.size
        prevLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        PLView.layer.addSublayer(prevLayer!)
        
        session?.startRunning()
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if device.position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.prevLayer?.connection.videoOrientation = self.transformOrientation(UIInterfaceOrientation(rawValue: UIApplication.sharedApplication().statusBarOrientation.rawValue)!)
            self.prevLayer?.frame.size = self.PLView.frame.size
            }, completion: { (context) -> Void in
                
        })
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    func transformOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .LandscapeLeft:
            return .LandscapeLeft
        case .LandscapeRight:
            return .LandscapeRight
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        default:
            return .Portrait
        }
    }
    
    
    // MARK: - Btn Event
    @IBAction func switchCamera(sender: AnyObject) {
        if let sess = session {
            let currentCameraInput: AVCaptureInput = sess.inputs[0] as! AVCaptureInput
            sess.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            if (currentCameraInput as! AVCaptureDeviceInput).device.position == .Back {
                newCamera = self.cameraWithPosition(.Front)!
            } else {
                newCamera = self.cameraWithPosition(.Back)!
            }
            
            
            do {
                let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
                if session!.canAddInput(newVideoInput) {
                    self.session?.addInput(newVideoInput)
                }
            } catch let error as NSError {
                input = nil
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    @IBAction func switchToAlbums(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhoto(sender: AnyObject){
        self.view.userInteractionEnabled = false
        
        if let videoConnection = imageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
    
                var image = UIImage(data: imageData)
                
                if (image != nil){
        
                //crop image like PLView
                image = self.cropCameraImage(image!, previewLayer: self.prevLayer!)
                self.onCompletion!(self.resizeImage(image!, newWidth: self.widthAndHeight, newHeight: self.widthAndHeight))
                    
                }else{
                    self.onCompletion!(nil)
                }
            }
        }
    }

    func cropCameraImage(original: UIImage, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        
        var image = UIImage()
        
        let previewImageLayerBounds = previewLayer.bounds
        
        let originalWidth = original.size.width
        let originalHeight = original.size.height
        
        let A = previewImageLayerBounds.origin
        let B = CGPointMake(previewImageLayerBounds.size.width, previewImageLayerBounds.origin.y)
        let D = CGPointMake(previewImageLayerBounds.size.width, previewImageLayerBounds.size.height)
        
        let a = previewLayer.captureDevicePointOfInterestForPoint(A)
        let b = previewLayer.captureDevicePointOfInterestForPoint(B)
        let d = previewLayer.captureDevicePointOfInterestForPoint(D)
        
        let posX = floor(b.x * originalHeight)
        let posY = floor(b.y * originalWidth)
        
        let width: CGFloat = d.x * originalHeight - b.x * originalHeight
        let height: CGFloat = a.y * originalWidth - b.y * originalWidth
        
        let cropRect = CGRectMake(posX, posY, width, height)
        
        if let imageRef = CGImageCreateWithImageInRect(original.CGImage, cropRect) {
            image = UIImage(CGImage: imageRef, scale: original.scale, orientation: original.imageOrientation)
        }
        
        return image
    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat , newHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func stopCamera() {
            self.session?.stopRunning()
            self.prevLayer?.removeFromSuperlayer()
            self.session = nil
            self.input = nil
            self.imageOutput = nil
            self.prevLayer = nil
            self.device = nil
    }
    
    // MARK: - imagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.onCompletion!(self.resizeImage(image!, newWidth: self.widthAndHeight, newHeight: self.widthAndHeight))
        self.stopCamera()
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}