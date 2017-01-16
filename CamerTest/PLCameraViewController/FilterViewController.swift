//
//  FilterViewController.swift
//  CamerSample
//
//  Created by Apple on 2017/1/12.
//  Copyright © 2017年 Yu-cheng Jhuo. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    var origanImage :UIImage!
    @IBOutlet var imageToFilter :UIImageView!
    @IBOutlet var originalImage :UIImageView!
    @IBOutlet var filtersScrollView :UIScrollView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    public var onComplete: TakeCameraCompletion?
    
//    var CIFilterNames = [
//        "Original" : "CIPhotoEffectChrome", //1 Original
//        "Lo-Fi" : "CIPhotoEffectFade",   //2 Lo-Fi
//        "Twilight" : "CIPhotoEffectInstant",//3 Twilight
//        "Darkness" : "CIPhotoEffectProcess",//5 Darkness
//        "Warm" : "CIPhotoEffectTransfer",//7 Warm
//        "Sunset" : "CIColorCrossPolynomial",//9 Sunset
//    ]
    
    var CIFilterNames = [
        "CIPhotoEffectChrome", //1 Original
        "CIPhotoEffectFade",   //2 Lo-Fi
        "CIPhotoEffectInstant",//3 Twilight
        
        "CIPhotoEffectProcess",//5 Darkness
        
        "CIPhotoEffectTransfer",//7 Warm
       
        "CIColorCrossPolynomial"//9 Sunset
       
    ]
    
    var CIFilterkey = [
        "Original", //1 Original
        "Lo-Fi",   //2 Lo-Fi
        "Twilight",//3 Twilight
        "Darkness",//5 Darkness
        "Warm",//7 Warm
        "Sunset"//9 Sunset
        
    ]
    
//    var CIFilterNames = [
//        "CIPhotoEffectChrome", //1 Original
//        "CIPhotoEffectFade",   //2 Lo-Fi
//        "CIPhotoEffectInstant",//3 Twilight
//        "CIPhotoEffectNoir",
//        "CIPhotoEffectProcess",//5 Darkness
//        "CIPhotoEffectTonal",
//        "CIPhotoEffectTransfer",//7 Warm
//        "CISepiaTone",
//        "CIColorCrossPolynomial",//9 Sunset
//        "CIColorCube",
//        "CIColorCubeWithColorSpace",
//        "CIColorInvert",
//        "CIColorMonochrome",
//        "CIColorPosterize",
//        "CIFalseColor",
//        "CIMaximumComponent",
//        "CIMinimumComponent",
//        "CIVignetteEffect",
//        "CIVignette"
//    ]
//    
//    var CIFilterkey = [
//        "CIPhotoEffectChrome", //1 Original
//        "CIPhotoEffectFade",   //2 Lo-Fi
//        "CIPhotoEffectInstant",//3 Twilight
//        "CIPhotoEffectNoir",
//        "CIPhotoEffectProcess",//5 Darkness
//        "CIPhotoEffectTonal",
//        "CIPhotoEffectTransfer",//7 Warm
//        "CISepiaTone",
//        "CIColorCrossPolynomial",//9 Sunset
//        "CIColorCube",
//        "CIColorCubeWithColorSpace",
//        "CIColorInvert",
//        "CIColorMonochrome",
//        "CIColorPosterize",
//        "CIFalseColor",
//        "CIMaximumComponent",
//        "CIMinimumComponent",
//        "CIVignetteEffect",
//        "CIVignette"
//    ]
    
    public init(image:UIImage) {
        self.origanImage  = image
        super.init(nibName: "FilterViewController", bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.originalImage.image = self.origanImage
        
        
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 5
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        //for i in 0..<CIFilterNames.count {
         for filterItem in  CIFilterNames{
            
            
            // Button properties
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
            
            filterButton.tag = itemCount
            filterButton.addTarget(self, action: #selector(FilterViewController.filterButtonTapped(sender:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            
            // CODE FOR FILTERS WILL BE ADDED HERE...
            // Create filters for each button
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(cgImage: originalImage.image!, options: .)
            
            print("key:" + CIFilterkey[itemCount])
            print("value:" + filterItem)
            let filter = CIFilter(name: "\(filterItem)" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            filterButton.setImage(imageForButton, for: .normal)
            
            
            let labText = UILabel(frame: CGRect(x: xCoord, y: yCoord, width: 100 , height: 20))
            labText.textColor = UIColor.white
            labText.text = CIFilterkey[itemCount]
            labText.font = UIFont.systemFont(ofSize: 12)
            labText.sizeToFit()
            labText.center = filterButton.center
            labText.frame.origin.y = labText.frame.origin.y + 50
            
            
             xCoord +=  buttonWidth + gapBetweenButtons
            filtersScrollView.addSubview(filterButton)
            filtersScrollView.addSubview(labText)
            itemCount = itemCount + 1
        } // END FOR LOOP
    
        
        
        // Resize Scroll View
        filtersScrollView.contentSize = CGSize(width: (buttonWidth) * CGFloat(itemCount) + 35, height: yCoord + 40)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    
    func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton
        
        imageToFilter.image = button.imageView?.image
    }

    @IBAction func confirmPhoto() {
        onComplete?(imageToFilter.image)
    }

    @IBAction func cancel() {
        onComplete?(nil)
    }
    
}
