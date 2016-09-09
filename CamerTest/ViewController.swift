import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var imageView :UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    @IBAction func GotoTakePhoto(){
        
        let camera =  PLCameraViewController(WidthAndHeight: 600)
        { image  in
            if (image != nil){
                self.imageView.image = image
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.presentViewController(camera, animated: true, completion: nil)
    }
    
}