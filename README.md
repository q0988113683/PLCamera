# PLCamera
Customized Square Camera for Swift - easy to use


# Photo



# Example:
```
let camera =  PLCameraViewController(WidthAndHeight: 600)
       { image  in
           if (image != nil){
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
self.presentViewController(camera, animated: true, completion: nil)
```
