//
//  LightStatusImagePickerController.swift
//  CamerSample
//
//  Created by Apple on 2017/1/11.
//  Copyright © 2017年 Yu-cheng Jhuo. All rights reserved.
//

import UIKit

class LightStatusImagePickerController: UIImagePickerController {
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}
