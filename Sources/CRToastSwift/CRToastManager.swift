import UIKit

func image(with view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
    defer { UIGraphicsEndImageContext() }
    if let context = UIGraphicsGetCurrentContext() {
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    return nil
}

public class CRToastManager : NSObject {
    /**
     Sets the default options that CRToast will use when displaying a notification
     @param defaultOptions A dictionary of the options that are to be used as defaults for all subsequent
     showNotificationWithOptions:completionBlock and showNotificationWithMessage:completionBlock: calls
     */
    public static func setDefaultOptions(_ options : CROptions) {
        CRToast.setDefaultOptions(options)
    }
    public static  func setDefaultOptions(_ options : [CRToastOptionKey : Any]) {
        setDefaultOptions(CROptions(options: options))
    }
    
    /**
     Queues a notification to be shown with a collection of options.
     @param options A dictionary of the options that are to be used when showing the notification, defaults
     will be used for all non present options. Options passed in will override defaults
     @param completion A completion block to be fired at the completion of the dismisall of the notification
     @param appearance A  block to be fired when the notification is actually shown -- notifications can queue,
     and this block will only fire when the notification actually becomes visible to the user. Useful for
     synchronizing sound / vibration.
     */
    public static func showNotification(with: [CRToastOptionKey : Any], appearance: (()->Void)? = nil, completion: @escaping (()->Void)) {
        showNotification(with: CROptions(options: with), appearance: appearance, completion: completion)
    }
    public static func showNotification(with: CROptions, appearance: (()->Void)? = nil, completion: @escaping (()->Void)) {
        CRToastManager.manager.addNotification(CRToast.notification(with: with, appearance: appearance, completion: completion))
    }
    /**
     Queues a notification to be shown with a given message
     @param message The notification message to be shown. Defaults will be used for all other notification
     properties
     @param completion A completion block to be fired at the completion of the dismisall of the notification
     */
    public static func showNotification(message: String, appearance: (()->Void)? = nil, completion: @escaping (()->Void)) {
        showNotification(with: [.text: message] as [CRToastOptionKey : Any], appearance: appearance, completion: completion)
    }
    
    /**
     Immediately begins the (un)animated dismisal of a notification
     @param animated If YES the notification will dismiss with its configure animation, otherwise it will immidiately disappear
     */
    public static func dismissNotification(animated: Bool) {
        CRToastManager.manager.dismissNotification(animated)
    }
    
    /**
     Immediately begins the (un)animated dismissal of a notification and canceling all others
     @param identifier `kCRToastIdentifierKey` specified for the toasts in queue. If no toasts are found with that identifier, none will be removed. If this parameter is nil, all notifications are dismissed
     @param animated If YES the notification will dismiss with its configure animation, otherwise it will immidiately disappear
     */
    public static func dismissAllNotifications(identifier: String? = nil, animated: Bool) {
        if let s = identifier {
            CRToastManager.manager.dismissAllNotifications(identifier: s, animated)
        } else {
            CRToastManager.manager.dismissAllNotifications(animated)
        }
    }
    
    /**
     Gets the array of notification identifiers currently in the @c CRToastManager notifications queue.
     If no identifier is specified for the @c kCRToastIdentifier when created, it will be excluded from this collection.
     */
    public static func notificationIdentifiersInQueue() -> [String] {
        return CRToastManager.manager.notificationIdentifiersInQueue()
    }
    
    /**
     Checks if there is a notification currently being displayed
     */
    public static func isShowingNotification() -> Bool {
        return CRToastManager.manager.showingNotification
    }
    
    static let manager = CRToastManager()
    static let kCRToastManagerCollisionBoundaryIdentifier:NSString = "kCRToastManagerCollisionBoundryIdentifier"
    typealias CRToastAnimationCompletionBlock = (Bool)->Void
    typealias CRToastAnimationStepBlock = ()->Void
    
    // MARK: instance stuff
    var showingNotification : Bool { return notifications.count > 0 }
    var notificationWindow : UIWindow
    var statusBarView : UIView?
    var notificationView : UIView?
    var notification : CRToast? { return notifications.first }
    var notifications : [CRToast] = []
    var gravityAnimationCompletion : ((Bool)->Void)?
    
    override init() {
        notificationWindow = CRToastWindow(frame: UIScreen.main.bounds)
        notificationWindow.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        notificationWindow.windowLevel = .statusBar
        notificationWindow.rootViewController = CRToastViewController()
        notificationWindow.rootViewController?.view.clipsToBounds = true
        //        notificationWindow.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        //        notificationWindow.rootViewController?.view.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        super.init()
    }
}

extension CRToastManager { // instance functions
    // MARK: inward Animations
    func CRToastInwardAnimationsBlock(_ manager : CRToastManager, toast: CRToast) -> CRToastAnimationStepBlock {
        return {
            manager.notificationView?.frame = manager.notificationWindow.rootViewController?.view.bounds ?? CGRect.zero
            manager.statusBarView?.frame = toast.statusBarViewAnimationFrame1
        }
    }
    
    func CRToastInwardAnimationsCompletionBlock(_ manager : CRToastManager, toast: CRToast, notificationUUIDString: String?) -> CRToastAnimationCompletionBlock {
        return { finished in
            if toast.timeInterval != Double.greatestFiniteMagnitude && toast.state == .entering {
                toast.state = .displaying
                if !toast.forceUserInteraction {
                    let deadlineTime = DispatchTime.now() + toast.timeInterval
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        if manager.notification?.state == .displaying && manager.notification?.uuid.uuidString == notificationUUIDString {
                            manager.gravityAnimationCompletion = nil
                            manager.CRToastOutwardAnimationsSetupBlock(manager)()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Outward Animations
    func CRToastOutwardAnimationsCompletionBlock(_ manager: CRToastManager, callout: [UIView]? = nil) -> CRToastAnimationCompletionBlock {
        return { finished in
            if manager.notification?.showActivityIndicator ?? false {
                (manager.notificationView as? CRToastView)?.activityIndicator.stopAnimating()
            }
            manager.notificationWindow.rootViewController?.view.gestureRecognizers = nil
            manager.notification?.state = .completed
            if let c = manager.notification?.completion {
                c()
            }
            if let uid = manager.notification?.uuid {
                manager.notifications.removeAll(where: { $0.uuid == uid })
            }
            
            for v in (manager.notificationWindow.rootViewController?.view.subviews ?? []) {
                v.removeFromSuperview()
            }
            for v in callout ?? [] {
                v.isHidden = false
            }
            if let notif = manager.notifications.first {
                manager.gravityAnimationCompletion = nil
                manager.displayNotification(notif)
            } else {
                manager.notificationWindow.isHidden = true
            }
        }
    }
    
    func CRToastOutwardAnimationsBlock(_ manager: CRToastManager) -> CRToastAnimationStepBlock {
        return {
            manager.notification?.state = .exiting
            manager.notification?.animator?.removeAllBehaviors()
            manager.notificationView?.frame = manager.notification?.notificationViewAnimationFrame2 ?? CGRect.zero
            manager.statusBarView?.frame = manager.notificationWindow.rootViewController?.view.bounds ?? CGRect.zero
        }
    }
    
    fileprivate func checkAnim(for view: UIView?, lastFrame: CGRect?, delay: Double, _ callback : @escaping ()->Void) {
        guard let view = view else { callback() ; return }
        guard let lastFrame = lastFrame else { callback() ; return }
        if view.frame == lastFrame {
            callback()
        } else {
            let f = CGRect(origin: view.frame.origin, size: view.frame.size)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
                self.checkAnim(for: view, lastFrame: f, delay: delay, callback)
            }
        }
    }
    fileprivate func setupOutGravity(_ manager: CRToastManager, callout: [UIView]? = nil) {
        let notification = manager.notification
        if manager.notification?.animator == nil {
            if let v = manager.notificationWindow.rootViewController?.view {
                manager.notification?.initiateAnimator(v)
            }
        }
        manager.notification?.animator?.removeAllBehaviors()
        var gv = [UIView]()
        if let v = manager.notificationView { gv.append(v) }
        if let v = manager.statusBarView { gv.append(v) }
        let gravity = UIGravityBehavior(items: gv)
        gravity.gravityDirection = notification?.outGravityDirection ?? CGVector(dx: 0, dy: -1)
        gravity.magnitude = notification?.gravityMagnitude ?? CROptions.default.gravityMagnitude
        
        var collisionItems = [UIView]()
        if let v = manager.notificationView { collisionItems.append(v) }
        if let v = manager.statusBarView {
            if notification?.presentationType == .push {
                collisionItems.append(v)
            }
        }
        let collision = UICollisionBehavior(items: collisionItems)
        collision.collisionDelegate = manager
        if let c = callout, let rootViewController = manager.notificationWindow.rootViewController {
            for vo in c {
                if vo.isHidden { continue }
                if vo.superview == rootViewController.view { continue } // views have to share the same parent
                let v = UIImageView(image: image(with: vo))
                v.frame = vo.superview!.convert(vo.frame, to: rootViewController.view)
                rootViewController.view.addSubview(v)
                collisionItems.append(v)
                let snap = UISnapBehavior(item: v, snapTo: v.center)
                notification?.animator?.addBehavior(snap)
                collision.addItem(v)
                vo.isHidden = true
            }
            
            let screenSize = UIScreen.main.bounds.size
            let outsideScreenBoundary = UIBezierPath(rect: CGRect(x: -screenSize.width, y: -screenSize.height, width: 3*screenSize.width, height: 3*screenSize.height))
            collision.addBoundary(withIdentifier: CRToastManager.kCRToastManagerCollisionBoundaryIdentifier, for: outsideScreenBoundary)
            rootViewController.view.frame.size = screenSize
            
            // One problem with "realistic" dynamics is that the notification might get stuck
            if let fc = manager.notificationView?.frame {
                let f = CGRect(origin: fc.origin, size: fc.size)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.checkAnim(for: manager.notificationView, lastFrame: f, delay: 0.2) {
                        if !manager.notificationWindow.isHidden {
                            if let c = manager.gravityAnimationCompletion { c(true) }
                        }
                    }
                }
            }
        } else {
            collision.addBoundary(withIdentifier: CRToastManager.kCRToastManagerCollisionBoundaryIdentifier,
                                  from: notification?.outCollisionPoint1 ?? CGPoint.zero,
                                  to: notification?.outCollisionPoint2 ?? CGPoint.zero)
        }
        if callout == nil {
            let rotLock = UIDynamicItemBehavior(items: collisionItems)
            rotLock.allowsRotation = false
            manager.notification?.animator?.addBehavior(rotLock)
        }
        manager.notification?.animator?.addBehavior(collision)
        manager.notification?.animator?.addBehavior(gravity)
        manager.gravityAnimationCompletion = CRToastOutwardAnimationsCompletionBlock(manager, callout: callout)
    }
    func CRToastOutwardAnimationsSetupBlock(_ manager: CRToastManager) -> CRToastAnimationStepBlock {
        return {
            let notification = manager.notification
            manager.notification?.state = .exiting
            manager.statusBarView?.frame = notification?.statusBarViewAnimationFrame2 ?? CGRect.zero
            manager.notificationWindow.gestureRecognizers?.forEach { recognizer in
                recognizer.isEnabled = false
            }
            
            if let animType = manager.notification?.animationTypeOut {
                switch animType {
                    
                case .linear:
                    UIView.animate(withDuration: notification?.animateOutTimeInterval ?? 0.5,
                                   delay: 0,
                                   options: [],
                                   animations: manager.CRToastOutwardAnimationsBlock(manager),
                                   completion: manager.CRToastOutwardAnimationsCompletionBlock(manager))
                case .spring:
                    UIView.animate(withDuration: notification?.animateOutTimeInterval ?? 0.5,
                                   delay: 0,
                                   usingSpringWithDamping: notification?.springDamping ?? 0.5,
                                   initialSpringVelocity: notification?.springInitialVelocity ?? 0.5,
                                   options: [],
                                   animations: manager.CRToastOutwardAnimationsBlock(manager),
                                   completion: manager.CRToastOutwardAnimationsCompletionBlock(manager))
                case .gravity:
                    manager.setupOutGravity(manager)
                case .dynamic(let views):
                    manager.setupOutGravity(manager, callout: views)
                }
            }
        }
    }
    
    func notificationIdentifiersInQueue() -> [String] {
        return notifications.map { toast -> String? in
            return toast.identifier
            }.compactMap { $0 }
    }
    
    func dismissNotification(_ animated: Bool) {
        if notifications.count == 0 { return }
        if animated && self.notification?.state == .entering || self.notification?.state == .displaying {
            CRToastOutwardAnimationsSetupBlock(self)()
        } else {
            CRToastOutwardAnimationsCompletionBlock(self)(true)
        }
    }
    
    func dismissAllNotifications(_ animated: Bool) {
        dismissNotification(animated)
        self.notifications.removeAll()
    }
    
    func dismissAllNotifications(identifier: String, _ animated: Bool) {
        if notifications.count == 0 { return }
        var indexes = IndexSet()
        var callDismiss = false
        
        notifications.enumerated().forEach( { (index, toast) in
            if let id = toast.identifier, id == identifier {
                if index == 0 { callDismiss = true }
                else { indexes.insert(index) }
            }
        })
        for i in indexes.reversed() { // last to first when punching holes
            notifications.remove(at: i)
        }
        if callDismiss {
            dismissNotification(animated)
        }
    }
    
    func addNotification(_ toast: CRToast) {
        if !self.showingNotification {
            self.displayNotification(toast)
        }
        notifications.append(toast)
    }
    
    func displayNotification(_ toast: CRToast) {
        if let ap = toast.appearance {
            ap()
        }
        
        notificationWindow.isHidden = false
        var notificationSize = CRNotificationViewSize(toast.toastType, toast.preferredHeight)
        if toast.keepNavigationBarBorder {
            notificationSize.height -= 1.0
        }
        
        let containerFrame = CRGetNotificationContainerFrame(CRGetDeviceOrientation(), notificationSize)
        
        if let rootViewController = notificationWindow.rootViewController as? CRToastViewController {
            rootViewController.statusBarStyle = toast.statusBarStyle
            rootViewController.autorotate = toast.autorotate
            rootViewController.notification = toast
            
            notificationWindow.rootViewController?.view.frame = containerFrame
            notificationWindow.windowLevel = toast.underStatusBar ? .normal + 1 : .statusBar
            
            let statusBarView = toast.statusBarView
            statusBarView.frame = rootViewController.view.bounds
            rootViewController.view.addSubview(statusBarView)
            self.statusBarView = statusBarView
            statusBarView.isHidden = toast.presentationType == .cover
            
            let notificationView = toast.notificationView
            if let tv = notificationView as? CRToastView {
                tv.toast = toast
            }
            notificationView.frame = toast.notificationViewAnimationFrame1
            rootViewController.view.addSubview(notificationView)
            self.notificationView = notificationView
            rootViewController.toastView = notificationView
            notificationView.isHidden = false
            
            for subview in rootViewController.view.subviews {
                subview.isUserInteractionEnabled = false
            }
            
            rootViewController.view.isUserInteractionEnabled = true
            rootViewController.view.gestureRecognizers = toast.gestureRecognizers
            
            let inwardAnimationBlock = CRToastInwardAnimationsBlock(self, toast: toast)
            let inwardAnimationCompletionBlock = CRToastInwardAnimationsCompletionBlock(self, toast: toast, notificationUUIDString: toast.uuid.uuidString)
            
            toast.state = .entering
            
            self.showNotification(toast, inward: inwardAnimationBlock, completion: inwardAnimationCompletionBlock)
            
            if toast.text.count > 0 || (toast.subtitleText?.count ?? 0) > 0 {
                // Synchronous notifications (say, tapping a button that presents a toast) cause VoiceOver to read the button immediately, which interupts the toast. A short delay (not the best solution :/) allows the toast to interupt the button.
                let deadlineTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    UIAccessibility.post(notification: .announcement, argument: "Alert: \(toast.text) \(toast.subtitleText ?? "")")
                }
            }
        }
    }
    
    fileprivate func setupInGravity(_ toast: CRToast, callout: [UIView]? = nil) {
        if let notificationView = self.notificationView, let statusBarView = self.statusBarView, let rootViewController = self.notificationWindow.rootViewController {
            toast.initiateAnimator(rootViewController.view)
            toast.animator?.removeAllBehaviors()
            
            let gravity = UIGravityBehavior(items: [notificationView, statusBarView])
            gravity.gravityDirection = toast.inGravityDirection
            gravity.magnitude = toast.gravityMagnitude
            var collisionItems = [notificationView]
            if toast.presentationType == .push {
                collisionItems.append(statusBarView)
            }
            if let c = callout {
                for vo in c {
                    if vo.superview == rootViewController.view { continue } // views have to share the same parent
                    let v = UIView(frame: vo.frame)
                    v.backgroundColor = UIColor.clear
                    rootViewController.view.addSubview(v)
                    collisionItems.append(v)
                    let snap = UISnapBehavior(item: v, snapTo: v.center)
                    toast.animator?.addBehavior(snap)
                }
            } else {
                let rotLock = UIDynamicItemBehavior(items: collisionItems)
                rotLock.allowsRotation = false
                toast.animator?.addBehavior(rotLock)
            }
            let collision = UICollisionBehavior(items: collisionItems)
            collision.collisionDelegate = self
            collision.addBoundary(withIdentifier: CRToastManager.kCRToastManagerCollisionBoundaryIdentifier,
                                  from: toast.inCollisionPoint1,
                                  to: toast.inCollisionPoint2)
            toast.animator?.addBehavior(collision)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                toast.animator?.addBehavior(gravity)
            }
        }
    }
    func showNotification(_ toast: CRToast, inward animation: @escaping CRToastAnimationStepBlock, completion: @escaping CRToastAnimationCompletionBlock) {
        switch toast.animationTypeIn {
        case .linear:
            UIView.animate(withDuration: toast.animateInTimeInterval,
                           animations: animation,
                           completion: completion)
        case .spring:
            UIView.animate(withDuration: toast.animateInTimeInterval,
                           delay: 0.0,
                           usingSpringWithDamping: toast.springDamping,
                           initialSpringVelocity: toast.springInitialVelocity,
                           animations: animation,
                           completion: completion)
        case .gravity:
            setupInGravity(toast)
            self.gravityAnimationCompletion = completion
        case .dynamic(let views):
            setupInGravity(toast, callout: views)
            self.gravityAnimationCompletion = completion
        }
    }
    
}

extension UIBezierPath {
    public func strokeImage(with color: UIColor) -> UIImage? {
        let w = self.bounds.size.width + self.lineWidth * 2
        let h = self.bounds.size.height + self.lineWidth * 2
        let bnds = CGRect(x: self.bounds.origin.x - self.lineWidth, y: self.bounds.origin.y - self.lineWidth, width: w, height: h)
        
        let v = UIView(frame: bnds)
        UIGraphicsBeginImageContextWithOptions(v.frame.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            v.layer.render(in: ctx)
            ctx.translateBy(x: -(bnds.origin.x - self.lineWidth), y: -(bnds.origin.y - self.lineWidth));
            color.set()
            self.stroke()
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return img
        } else {
            return nil
        }
    }
    
    public func fillImage(with color: UIColor) -> UIImage? {
        let w = self.bounds.size.width + self.lineWidth * 2
        let h = self.bounds.size.height + self.lineWidth * 2
        let bnds = CGRect(x: self.bounds.origin.x - self.lineWidth, y: self.bounds.origin.y - self.lineWidth, width: w, height: h)
        
        let v = UIView(frame: bnds)
        UIGraphicsBeginImageContextWithOptions(v.frame.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            v.layer.render(in: ctx)
            ctx.translateBy(x: -(bnds.origin.x - self.lineWidth), y: -(bnds.origin.y - self.lineWidth));
            color.set()
            self.fill()
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return img
        } else {
            return nil
        }
    }
    
    public static func star(size: CGFloat) -> UIBezierPath {
        let bp = UIBezierPath()
        
        bp.move(to: CGPoint(x: size*0.5, y: 0))
        bp.addCurve(to: CGPoint(x: size, y: size*0.5), controlPoint1: CGPoint(x: size*0.5, y: size*0.25), controlPoint2: CGPoint(x: size*0.75, y: size*0.5))
        bp.addCurve(to: CGPoint(x: size*0.5, y: size), controlPoint1: CGPoint(x: size*0.75, y: size*0.5), controlPoint2: CGPoint(x: size*0.5, y: size*0.75))
        bp.addCurve(to: CGPoint(x: 0, y: size*0.5), controlPoint1: CGPoint(x: size*0.5, y: size*0.75), controlPoint2: CGPoint(x: size*0.25, y: size*0.5))
        bp.addCurve(to: CGPoint(x: size*0.5, y: 0), controlPoint1: CGPoint(x: size*0.25, y: size*0.5), controlPoint2: CGPoint(x: size*0.5, y: size*0.25))
        bp.close()
        
        return bp
    }
}

extension CRToastManager : UICollisionBehaviorDelegate {
    /*
    // for funsies, emit particles from the point of contact
    func createParticles(in view: UIView, at point: CGPoint) -> CAEmitterLayer {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = point
        particleEmitter.emitterShape = .circle
        particleEmitter.emitterSize = CGSize(width: 15, height: 15)
        
        
        let red = makeEmitterCell(color: UIColor.red)
        let green = makeEmitterCell(color: UIColor.green)
        let blue = makeEmitterCell(color: UIColor.blue)
        
        particleEmitter.emitterCells = [red, green, blue]
        
        view.layer.addSublayer(particleEmitter)
        return particleEmitter
    }
    
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 30
        cell.lifetime = 1.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 400
        cell.velocityRange = 50
        cell.emissionLongitude = -CGFloat.pi / 2
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        
        cell.contents = UIBezierPath.star(size: 6).strokeImage(with: UIColor.white)?.cgImage
        return cell
    }
 
    public func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        // this space for rent
    }
 
    public func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        if let _ = item1 as? CRToastView { // ignore
        } else {
            if let v = item1 as? UIView, let p = self.notificationWindow.rootViewController?.view.convert(p, to: v) {
                if (v.layer.sublayers ?? []).filter({ (l) -> Bool in
                    return (l as? CAEmitterLayer) != nil
                }).count != 0 { return }
                let particles = createParticles(in: v, at: p)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
                    particles.removeFromSuperlayer()
                }
            }
        }
        if let _ = item2 as? CRToastView { // ignore
        } else {
             if let v = item2 as? UIView, let p = self.notificationWindow.rootViewController?.view.convert(p, to: v) {
                if (v.layer.sublayers ?? []).filter({ (l) -> Bool in
                    return (l as? CAEmitterLayer) != nil
                }).count != 0 { return }
                let particles = createParticles(in: v, at: p)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
                    particles.removeFromSuperlayer()
                }
            }
        }
    }

     */

    public func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        if let cb = self.gravityAnimationCompletion {
            cb(true)
        }
    }
    
    public func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        if let _ = item1 as? CRToastView { // ignore
        } else {
            // print("pong \(item1)")
        }
        if let _ = item2 as? CRToastView { // ignore
        } else {
            // print("pong \(item1)")
        }
    }
}


// MARK: -
extension CRToast {
    static func setDefaultOptions(_ options : CROptions) {
        // TODO
        // CROptions.default = options
    }
    static func setDefaultOptions(_ options : [CRToastOptionKey : Any]) {
        setDefaultOptions(CROptions(options: options))
    }
    
    static func notification(with: [CRToastOptionKey : Any], appearance: (()->Void)?, completion: @escaping ()->Void) -> CRToast {
        return notification(with: CROptions(options: with), appearance: appearance, completion: completion)
    }
    static func notification(with: CROptions, appearance: (()->Void)?, completion: @escaping ()->Void) -> CRToast {
        let toast = CRToast()
        toast.options = with
        toast.completion = completion
        toast.state = .waiting
        toast.uuid = UUID()
        toast.appearance = appearance
        
        return toast
    }
    
}
