//
//  FilterSettingViewController.swift
//  CamerSample
//
//  Created by Yu chengJhuo on 3/3/17.
//  Copyright © 2017 Yu-cheng Jhuo. All rights reserved.
//

import UIKit

enum FilterSettingType {
    case Brightness
    case Saturation
    case Contrast
}

public typealias FilterCompletion = (UIImage?) -> Void

class FilterSettingViewController: UIViewController {
    var filterOriganImage :UIImage!
    var filterSettingType : FilterSettingType = .Brightness
    var FilterComplete: FilterCompletion?
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var imageToFilter :UIImageView!
    
    public init(image:UIImage) {
        self.filterOriganImage  = image
        super.init(nibName: "FilterSettingViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageToFilter.image = filterOriganImage
        slider.removeTarget(self, action: nil, for: .allEvents)
        switch filterSettingType {
        case .Brightness:
            slider.minimumValue = -1;
            slider.maximumValue = 1;
            slider.value = 0
            slider.setThumbImage(UIImage(named:"brightness.png"), for: .normal)
            slider.setThumbImage(UIImage(named: "brightness.png"), for: .highlighted)
            slider.backgroundColor = UIColor(white: 0, alpha: 0.3)
            slider.layer.cornerRadius = 15
            slider.addTarget(self, action: #selector(FilterSettingViewController.BrightnessSetting(sender:)), for: .valueChanged)
            break
        case .Saturation:
            slider.minimumValue = 0;
            slider.maximumValue = 2;
            slider.value = 1
            slider.setThumbImage(UIImage(named:"saturation.png"), for: .normal)
            slider.setThumbImage(UIImage(named: "saturation.png"), for: .highlighted)
            slider.backgroundColor = UIColor(white: 0, alpha: 0.3)
            slider.layer.cornerRadius = 15
            slider.addTarget(self, action: #selector(FilterSettingViewController.SaturationValueChanged(sender:)), for: .valueChanged)
            break
        case .Contrast:
            slider.minimumValue = 0.5;
            slider.maximumValue = 1.5;
            slider.value = 1
            slider.setThumbImage(UIImage(named:"contrast.png"), for: .normal)
            slider.setThumbImage(UIImage(named: "contrast.png"), for: .highlighted)
            slider.backgroundColor = UIColor(white: 0, alpha: 0.3)
            slider.layer.cornerRadius = 15
            slider.addTarget(self, action: #selector(FilterSettingViewController.ContrastValueChanged(sender:)), for: .valueChanged)
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disminssView(sender:UISlider) {
         _ =  self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func submitView(sender:UISlider) {
         FilterComplete?(self.imageToFilter.image)
         _ =  self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func sliderValueChange(sender:UISlider) {
        print(sender.value)
    }
    
    @objc func BrightnessSetting(sender:UISlider)
    {
        self.imageToFilter.image = PLCameraTool.filteredWithBrightness(self.filterOriganImage, brightnessT:sender.value)
    }
    
    @objc func SaturationValueChanged(sender:UISlider)
    {
        self.imageToFilter.image = PLCameraTool.filteredWithSaturation(self.filterOriganImage, Saturation: sender.value)
    }
    
    @objc func ContrastValueChanged(sender:UISlider)
    {
        self.imageToFilter.image = PLCameraTool.filteredWithContrast(self.filterOriganImage, contrastT: sender.value)
    }
    
}
