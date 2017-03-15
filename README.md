## PLCamera
Customized Square Camera for Swift - easy to use


## Photo

![](https://github.com/q0988113683/PLCamera/blob/master/IMG_4195.PNG)


## Requirements
iOS 9.0+
Xcode 8.0+
Swift 3.0+

## Example:
```
let camera =  PLCameraViewController(WidthAndHeight: 600)
       { image  in
           if (image != nil){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
self.presentViewController(camera, animated: true, completion: nil)
```
