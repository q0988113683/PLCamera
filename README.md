## PLCamera
Customized Square Camera for Swift - easy to use


## Photo

![](https://github.com/q0988113683/PLCamera/blob/master/CameraVideo720.gif)


## Requirements
iOS 9.0+
Xcode 8.0+
Swift 3.0+

## Example:
```
let camera =  PLCameraViewController(WidthAndHeight: 600)
        { image  in
            if (image != nil){
                // set image
            }
            self.dismiss(animated: true, completion: nil)
        }
self.present(camera, animated: true, completion: nil)
```
