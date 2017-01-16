//
//  PLCameraViewController.swift
//  CamerTest
//
//  Created by Yu chengJhuo on 9/4/16.
//  Copyright © 2016 Yu-cheng Jhuo. All rights reserved.
import UIKit
import AVFoundation
import Photos

public typealias TakeCameraCompletion = (UIImage?) -> Void

class PLCameraViewController: UIViewController{
    
    
    @IBOutlet weak var PLView: UIView!
    var onCompletion: TakeCameraCompletion?
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput!
    var prevLayer: AVCaptureVideoPreviewLayer?
    var widthAndHeight : CGFloat = 500
    var switchCamera  = false
    @IBOutlet weak var focusView: UIView!
    @IBOutlet weak var btnFlash: UIButton!
    
    var isCloseCamera = false
    
    init(WidthAndHeight: CGFloat , completion: @escaping TakeCameraCompletion) {
        super.init(nibName: nil, bundle: nil)
        self.widthAndHeight = WidthAndHeight
        onCompletion = completion
    }
    
    init(WidthAndHeight: CGFloat , switchCamera : Bool ,  completion: @escaping TakeCameraCompletion) {
        super.init(nibName: nil, bundle: nil)
        self.widthAndHeight = WidthAndHeight
        onCompletion = completion
        
        self.switchCamera = switchCamera
        
    }
    
    init(WidthAndHeight: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.widthAndHeight = WidthAndHeight
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession()
        
        focusView.layer.borderWidth = 1.0
        focusView.layer.borderColor = UIColor(red: 181.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
        focusView.isHidden = true
        
        
        if let gestureRecognizers = self.view.gestureRecognizers {
            gestureRecognizers.forEach({ self.view.removeGestureRecognizer($0) })
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focus(_:)))
        self.view.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
        self.view.addSubview(focusView)
        if  switchCamera == true  && input != nil{
            self.switchCamera(switchCamera as AnyObject)
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (isCloseCamera){
            self.ShowOpenCameraAlert()
        }
        
        
        prevLayer?.frame.size = PLView.frame.size
        
        self.focusCamera(self.PLView.center)
    }
    
    
    // MARK: - Btn Event
    @IBAction func switchCamera(_ sender: AnyObject) {
        if let sess = session {
            let currentCameraInput: AVCaptureInput = sess.inputs[0] as! AVCaptureInput
            sess.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
                newCamera = self.cameraWithPosition(.front)!
            } else {
                newCamera = self.cameraWithPosition(.back)!
            }
            
            do {
                let newVideoInput = try AVCaptureDeviceInput(device: newCamera)
                if session!.canAddInput(newVideoInput) {
                    self.session?.addInput(newVideoInput)
                }
            } catch let error as NSError {
                input = nil
                self.isCloseCamera = true
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    @IBAction func switchToAlbums(_ sender: AnyObject) {
        
        guard self.isAvailablePhotoLibrary() else {
            onCompletion!(nil)
            return
        }
        
        self.present( self.CreateImagePicker() , animated: true, completion: nil)
    }
    
    @IBAction func takePhotoClick(_ sender: AnyObject){
        self.view.isUserInteractionEnabled = false
        
        guard imageOutput != nil else {
            return
        }
        
        
        if let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo) {
            imageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                if (imageDataSampleBuffer != nil){
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                    var image = UIImage(data: imageData!)
                    
                    if (image != nil){
                        
                        //crop image like PLView
                        image = self.cropCameraImage(image!, previewLayer: self.prevLayer!)
                        image = self.resizeImage(image!, newWidthX: self.widthAndHeight, newHeightX: self.widthAndHeight)
                        
                        
                        let filterController = FilterViewController(image: image!)
                        filterController.onComplete = { image in
                            if var image = image {
                                self.onCompletion!(image)
                                self.stopCamera()
                            }else{
                                self.view.isUserInteractionEnabled = true
                            }
                           
                            self.dismiss(animated: true, completion: nil);
                        }
                        let nav = UINavigationController(rootViewController: filterController)
                        nav.navigationBar.barTintColor = UIColor.black
                        self.present(nav, animated: true, completion: nil)
                        
                        
                    }else{
                        self.onCompletion!(nil)
                        self.stopCamera()
                    }
                    
                }
            }
        }
    }
    
    @IBAction func ExitPhotoClick(_ sender: AnyObject){
        self.ExitView()
        
    }
    
    func ExitView() {
        self.view.isUserInteractionEnabled = false
        self.stopCamera()
        self.onCompletion!(nil)
    }
    
    @IBAction func FlashClick(){
        do {
            try device!.lockForConfiguration()
            if (device?.flashMode == .auto){
                device?.flashMode = .on
                btnFlash.setImage(UIImage(named: "flashOn") , for: UIControlState())
            }else if (device?.flashMode == .on){
                device?.flashMode = .off
                btnFlash.setImage(UIImage(named: "flashOff") , for: UIControlState())
            }else{
                device?.flashMode = .auto
                btnFlash.setImage(UIImage(named: "flashAuto") , for: UIControlState())
            }
            device!.unlockForConfiguration()
        } catch _ { }
    }
    
    
    
    // MARK: - Private Method
    internal func focus(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self.view)
        CameraAnimaion(point)
        
    }
    
    internal func CameraAnimaion(_ point : CGPoint){
        guard focusCamera(point) else {
            return
        }
        
        focusView.isHidden = false
        focusView.center = point
        focusView.alpha = 0
        focusView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        self.view.bringSubview(toFront: focusView)
        
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.15, animations: { () -> Void in
                self.focusView.alpha = 1
                self.focusView.transform = CGAffineTransform.identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.80, relativeDuration: 0.20, animations: { () -> Void in
                self.focusView.alpha = 0
                self.focusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            })
            
            
        }, completion: { finished in
            if finished {
                self.focusView.isHidden = true
            }
        })
    }
    
    @discardableResult internal func focusCamera(_ toPoint: CGPoint) -> Bool {
        
        guard toPoint.y > self.PLView.frame.origin.y && toPoint.y < self.PLView.frame.origin.y + self.PLView.frame.size.height else {
            return false
        }
        
        guard let device = device , device.isFocusModeSupported(.continuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        // focus points are in the range of 0...1, not screen pixels
        let focusPoint = CGPoint(x: toPoint.x / self.view.frame.width, y: toPoint.y / self.view.frame.height)
        
        device.focusMode = AVCaptureFocusMode.continuousAutoFocus
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
        device.unlockForConfiguration()
        
        return true
    }
    
    func cropCameraImage(_ original: UIImage, previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {
        
        var image = UIImage()
        
        let previewImageLayerBounds = previewLayer.bounds
        
        let originalWidth = original.size.width
        let originalHeight = original.size.height
        
        let A = previewImageLayerBounds.origin
        let B = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.origin.y)
        let D = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.size.height)
        
        let a = previewLayer.captureDevicePointOfInterest(for: A)
        let b = previewLayer.captureDevicePointOfInterest(for: B)
        let d = previewLayer.captureDevicePointOfInterest(for: D)
        
        let posX = floor(b.x * originalHeight)
        let posY = floor(b.y * originalWidth)
        
        let width: CGFloat = d.x * originalHeight - b.x * originalHeight
        let height: CGFloat = a.y * originalWidth - b.y * originalWidth
        
        let cropRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        if let imageRef = original.cgImage?.cropping(to: cropRect) {
            image = UIImage(cgImage: imageRef, scale: original.scale, orientation: original.imageOrientation)
        }
        
        return image
    }
    
    func resizeImage(_ image: UIImage, newWidthX: CGFloat , newHeightX: CGFloat) -> UIImage {
        var newWidth = newWidthX
        var newHeight = newHeightX
        if (image.size.width < newWidth){
            newWidth = image.size.width
            newHeight = image.size.width
        }
        //        let scale = newWidth / image.size.width
        //        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
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
    
    
    func createSession() {
        session = AVCaptureSession()
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            input = nil
            self.isCloseCamera = true
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
    
    func ShowOpenCameraAlert() {
        
        let alert = UIAlertController(title: "", message: "Please Allow Access to Your Camera.\n Go Setting", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
             self.ExitView()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.openURL(settingsUrl)
            }
            self.ExitView()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in devices! {
            if (device as AnyObject).position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.prevLayer?.connection.videoOrientation = self.transformOrientation(UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
            self.prevLayer?.frame.size = self.PLView.frame.size
        }, completion: { (context) -> Void in
            
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func transformOrientation(_ orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    func CreateImagePicker() -> UIImagePickerController{
        
        let imagePicker = LightStatusImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
        imagePicker.allowsEditing = false
        imagePicker.navigationBar.barTintColor = UIColor.black
        imagePicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        imagePicker.navigationBar.tintColor =  .white
        return imagePicker
        
    }
    
    func isAvailablePhotoLibrary() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
    }
}

extension PLCameraViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        if (image.size.width != image.size.height){
        
            self.dismiss(animated: true, completion: nil);
            
            let imageUrl = info["UIImagePickerControllerReferenceURL"]
            let asset = PHAsset.fetchAssets(withALAssetURLs: [imageUrl as! URL], options: nil).firstObject
            
            if (asset != nil){
                let confirmController = CropViewController(phasset: asset!, image: image)
                confirmController.onComplete = { image in
                   
                    if var image = image {
                        image = self.resizeImage(image, newWidthX: self.widthAndHeight, newHeightX: self.widthAndHeight)
                        
                        let filterController = FilterViewController(image: image)
                        
                        filterController.onComplete = { image in
                             if let image = image {
                                self.onCompletion!(image)
                                self.stopCamera()
                             }else{
                            }
                            self.dismiss(animated: true, completion: nil);
                        }
                        confirmController.navigationController?.pushViewController(filterController, animated: true)
                        
                      
                    }else{
                         self.dismiss(animated: true, completion: nil);
                    }
                }
             
                confirmController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                let nav = UINavigationController(rootViewController: confirmController)
                nav.navigationBar.barTintColor = UIColor.black
                self.present(nav, animated: true, completion: nil)
                
            }else{
                
                self.onCompletion!(self.resizeImage(image, newWidthX: self.widthAndHeight, newHeightX: self.widthAndHeight))
                self.stopCamera()
                self.dismiss(animated: true, completion: nil);
            }
        }else{
            self.dismiss(animated: true, completion: nil);
            let filterController = FilterViewController(image: image)
            
            filterController.onComplete = { image in
                if var image = image {
                    
                    if (image.size.width > self.widthAndHeight){
                         image = self.resizeImage(image, newWidthX: self.widthAndHeight, newHeightX: self.widthAndHeight)
                    }
                    
                    self.onCompletion!(image)
                    self.stopCamera()
                }else{
                }
                self.dismiss(animated: true, completion: nil);
            }
            
            filterController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            let nav = UINavigationController(rootViewController: filterController)
            nav.navigationBar.barTintColor = UIColor.black
            self.present(nav, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}




