import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var imageView :UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    @IBAction func GotoTakePhoto(){
        
        let camera =  PLCameraViewController(WidthAndHeight: 600)
        { image  in
            if (image != nil){
                self.imageView.image = image
            }
            self.dismiss(animated: true, completion: nil)
        }
        
        self.present(camera, animated: true, completion: nil)
    }

    
}
