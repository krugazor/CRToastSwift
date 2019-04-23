import UIKit

let iOS9 = floor(NSFoundationVersionNumber) >= floor(NSFoundationVersionNumber_iOS_9_0)

class CRToastContainerView : UIView {
    
}

public class CRToastViewController : UIViewController {
    public var autorotate : Bool = true
    public var notification : CRToast?
    public var toastView : UIView?
    public var statusBarStyle : UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK : UIViewController
    public override var shouldAutorotate: Bool { return autorotate }
    
    public override var prefersStatusBarHidden: Bool { return UIApplication.shared.isStatusBarHidden }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    public override func loadView() {
        self.view = CRToastContainerView(frame: CGRect.zero)
    }
    
    public override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        super.willAnimateRotation(to: toInterfaceOrientation, duration: duration)
        
        if let tv = self.toastView, let n = self.notification {
            let notificationSize = CRNotificationViewSizeForOrientation(n.toastType, n.preferredHeight, toInterfaceOrientation)
            tv.frame = CGRect(x: 0, y: 0, width: notificationSize.width, height: notificationSize.height)
        }
    }
        
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let tv = self.toastView, let n = self.notification {
            let notificationSize = CRNotificationViewSize(n.toastType, n.preferredHeight)
            tv.frame = CGRect(x: 0, y: 0, width: notificationSize.width, height: notificationSize.height)
        }
    }
}
