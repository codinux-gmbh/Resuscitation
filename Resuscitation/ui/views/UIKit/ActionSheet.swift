import UIKit


class ActionSheet : UIAlertBase {
    
    convenience init(_ title: String? = nil, _ actions: UIAlertAction...) {
        self.init(title, actions)
    }
    
    init(_ title: String? = nil, _ actions: [UIAlertAction] = []) {
        super.init(title: title, message: nil, .actionSheet, actions)
    }
    

    func show() {
        if let rootViewController = SceneDelegate.rootViewController {
            let alert = createAlertController()
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
            }
            
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
}
