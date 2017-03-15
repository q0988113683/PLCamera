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
    var smallImage : UIImage!
    var filterOriganImage :UIImage!
    var originalImage :UIImage!
    
    @IBOutlet var imageToFilter :UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate var selectFilterIndex =  0
    fileprivate let context = CIContext(options: nil)
    fileprivate var filterImageArray : [UIImage] = []
    
    public var onComplete: TakeCameraCompletion?
    
    var CIFilterNames = [
        "",
        "CIPhotoEffectFade",   //2 Lo-Fi
        "CIPhotoEffectInstant",//3 Twilight
        "CIPhotoEffectProcess",//5 Darkness
        "CIPhotoEffectTransfer",//7 Warm
        "CISepiaTone"//9 Sunset
    ]

    
    var CIFilterkey = [
        "Original", //0 Original
        "Lo-Fi",   //2 Lo-Fi
        "Twilight",//3 Twilight
        "Darkness",//5 Darkness
        "Warm",//7 Warm
        "Sunset",//9 Sunset
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
        self.originalImage = self.origanImage
        self.filterOriganImage = self.origanImage
        self.imageToFilter.image = self.origanImage
        
        self.smallImage = PLCameraTool.resizeImage(self.originalImage, newWidthX: 200, newHeightX: 200)
        self.filterImageArray.append(self.smallImage)
        
        collectionView?.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBAction func confirmPhoto() {
        onComplete?(imageToFilter.image)
        
        self.originalImage = nil
        self.smallImage = nil
        self.filterImageArray = []
        self.filterOriganImage = nil
    }
    
    @IBAction func cancel() {
        self.originalImage = nil
        self.smallImage = nil
        self.filterImageArray = []
        self.filterOriganImage = nil
        onComplete?(nil)
    }
    
    
    @IBAction func BrightnessSetting()
    {
       let filterController = FilterSettingViewController(image: self.imageToFilter.image!)
        filterController.filterSettingType = .Brightness
        filterController.FilterComplete = { image in
            if let image = image {
               self.imageToFilter.image = image
            }
        }
        self.navigationController?.pushViewController(filterController, animated: false)
    }
    
    @IBAction func SaturationValueChanged()
    {
        let filterController = FilterSettingViewController(image: self.imageToFilter.image!)
        filterController.filterSettingType = .Saturation
        filterController.FilterComplete = { image in
            if let image = image {
                self.imageToFilter.image = image
            }
        }
        self.navigationController?.pushViewController(filterController, animated: false)
    }
    
    @IBAction func ContrastValueChanged()
    {
        let filterController = FilterSettingViewController(image: self.imageToFilter.image!)
        filterController.filterSettingType = .Contrast
        filterController.FilterComplete = { image in
            if let image = image {
                self.imageToFilter.image = image
            }
        }
        self.navigationController?.pushViewController(filterController, animated: false)
    }
}


extension  FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        var filteredImage = self.smallImage
        
        if (filterImageArray.count >= indexPath.row + 1){
            filteredImage = self.filterImageArray[indexPath.row]
        }else{
            filteredImage = setFilterImage(filterName: CIFilterNames[indexPath.row] , image: filteredImage!)
            self.filterImageArray.append(filteredImage!)
        }
        
        cell.imageView.image = filteredImage
        cell.filterNameLabel.text = CIFilterkey[indexPath.row]
        cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CIFilterNames.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let oldSelectedCell = collectionView.cellForItem(at: IndexPath(row: self.selectFilterIndex, section: 0)) {
            let cell = oldSelectedCell as! FilterCollectionViewCell
            cell.filterNameLabel.font = UIFont.systemFont(ofSize: 14)
        }
        
        
        if let selectedCell = collectionView.cellForItem(at: IndexPath(row: indexPath.row, section: 0)) {
            let cell = selectedCell as! FilterCollectionViewCell
            
            cell.filterNameLabel.font = UIFont.boldSystemFont(ofSize: 14)
            
            if (indexPath.row != 0){
                let filterImage = self.setFilterImage(filterName: CIFilterNames[indexPath.row], image: self.originalImage)
                self.imageToFilter.image = filterImage
                self.filterOriganImage = filterImage
            }else{
                self.imageToFilter.image = self.originalImage
                self.filterOriganImage = self.originalImage
            }
        }
        
        selectFilterIndex = indexPath.row
        
        scrollCollectionViewToIndex(itemIndex: indexPath.item)
    }
    
    func scrollCollectionViewToIndex(itemIndex: Int) {
        let indexPath = IndexPath(item: itemIndex, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    
    func setFilterImage(filterName: String , image: UIImage) -> UIImage {
        // 1 - create source image
        let sourceImage = CIImage(image: image)
        
        // 2 - create filter using name
        let filter = CIFilter(name: filterName)
        filter?.setDefaults()
        
        // 3 - set source image
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        
        // 4 - output filtered image as cgImage with dimension.
        let outputCGImage = context.createCGImage((filter?.outputImage!)!, from: (filter?.outputImage!.extent)!)
        
        // 5 - convert filtered CGImage to UIImage
        let filteredImage = UIImage(cgImage: outputCGImage!)
        
        return filteredImage
    }
}
