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
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone",
        "CIColorCrossPolynomial",
        "CIColorCube",
        "CIColorCubeWithColorSpace",
        "CIColorInvert",
        "CIColorMonochrome",
        "CIColorPosterize",
        "CIFalseColor",
        "CIMaximumComponent",
        "CIMinimumComponent",
        "CIVignetteEffect",
        "CIVignette"
    ]
    
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
        
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
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
            let coreImage = CIImage(image: originalImage.image!)
            print(CIFilterNames[i])
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!);
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            xCoord +=  buttonWidth + gapBetweenButtons
            filtersScrollView.addSubview(filterButton)
        } // END FOR LOOP
        
        
        // Resize Scroll View
        filtersScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2)+30, height: yCoord)
        
        
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
        
        imageToFilter.image = button.backgroundImage(for: UIControlState.normal)
    }

    @IBAction func confirmPhoto() {
        onComplete?(imageToFilter.image)
    }

    @IBAction func cancel() {
        onComplete?(nil)
    }
    
}
