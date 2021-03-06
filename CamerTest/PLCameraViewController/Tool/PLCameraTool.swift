//
//  PLCameraTool.swift
//  CamerSample
//
//  Created by Yu chengJhuo on 1/23/17.
//  Copyright © 2017 Yu-cheng Jhuo. All rights reserved.
//

import UIKit

class PLCameraTool: NSObject {
    
    
    static func resizeImage(_ image: UIImage, newWidthX: CGFloat , newHeightX: CGFloat) -> UIImage {
        var newWidth = newWidthX
        var newHeight = newHeightX
        if (image.size.width < newWidth){
            newWidth = image.size.width
            newHeight = image.size.width
        }
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    static func filteredWithBrightness(_ image: UIImage, brightnessT: Float) -> UIImage? {
        
        guard let ciimage = CIImage(image: image) else {
            return nil
        }
        let filter = CIFilter(name: "CIExposureAdjust", withInputParameters: [kCIInputImageKey: ciimage])
        filter?.setDefaults()
        let brightness: CGFloat = CGFloat(2 * brightnessT)
        filter?.setValue(brightness, forKey: kCIInputEVKey)
        
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: (false)])
        let outputImage = filter?.outputImage
        let cgImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let result = UIImage(cgImage: cgImage!)
        return result
    }
    
    
    static func filteredWithSaturation(_ image: UIImage, Saturation: Float) -> UIImage? {
        guard let ciimage = CIImage(image: image) else {
            return nil
        }
        let filter = CIFilter.init(name: "CIColorControls")
        filter?.setValue(ciimage, forKey: kCIInputImageKey)
        filter?.setValue(Saturation, forKey: kCIInputSaturationKey)
        let result = filter?.value(forKey: kCIOutputImageKey) as! CIImage
        let cgimage = CIContext.init(options: nil).createCGImage(result, from: result.extent)
        let image = UIImage.init(cgImage: cgimage!)
        return image
    }

    
    static func filteredWithContrast(_ image: UIImage, contrastT: Float) -> UIImage? {
        guard let beginImage = CIImage(image: image) else {
            return nil
        }
        let parameters = [kCIInputImageKey      : beginImage,
                          kCIInputContrastKey   : contrastT
                          ] as [String : Any]
        
        let outputImage = CIFilter(name: "CIColorControls",
                                     withInputParameters: parameters)?.outputImage

        let context = CIContext(options: [kCIContextUseSoftwareRenderer: (false)])
        let cgImage = context.createCGImage(outputImage!, from: outputImage!.extent)
        let result = UIImage(cgImage: cgImage!)
        return result
    }
    
}
