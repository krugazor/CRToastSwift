//
//  ViewController.swift
//  CRToastDemo
//
//  Created by Nicolas Zinovieff on 3/3/19.
//  Copyright © 2019 CRToast. All rights reserved.
//

import UIKit
import CRToastSwift

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var segFromDirection: UISegmentedControl!
    @IBOutlet weak var segToDirection: UISegmentedControl!
    @IBOutlet weak var inAnimationType: UISegmentedControl!
    @IBOutlet weak var outAnimationType: UISegmentedControl!
    @IBOutlet weak var imageAlignment: UISegmentedControl!
    @IBOutlet weak var activityIndicatorAlignment: UISegmentedControl!
    @IBOutlet weak var notificationTextAlignment: UISegmentedControl!
    @IBOutlet weak var subtitleTextAlignment: UISegmentedControl!
    
    @IBOutlet weak var duration: UISlider!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var imageTint: UISlider!
    @IBOutlet weak var imageTintEnabled: UISwitch!
    @IBOutlet weak var padding: UISlider!
    @IBOutlet weak var paddingLbl: UILabel!
    
    @IBOutlet weak var imageEnabled: UISwitch!
    @IBOutlet weak var activityIndicatorEnabled: UISwitch!
    @IBOutlet weak var coverNavBarEnabled: UISwitch!
    @IBOutlet weak var slideOverEnabled: UISwitch!
    @IBOutlet weak var statusBarVisibleLbl: UILabel! // for boink purposes
    @IBOutlet weak var statusBarVisibleEnabled: UISwitch!
    @IBOutlet weak var dismissWithTapEnabled: UISwitch!
    @IBOutlet weak var viewControllerStatusBarEnabled: UISwitch!
    @IBOutlet weak var viewControllerNavBarEnabled: UISwitch!
    @IBOutlet weak var forceUserInteractionEnabled: UISwitch!
    
    @IBOutlet weak var text: UITextField!
    @IBOutlet weak var subtitle: UITextField!
    
    @IBOutlet weak var debugStar: UIImageView!
    @objc func keyboardWillShow(_ notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets(top: self.topLayoutGuide.length,
                                                    left: 0,
                                                    bottom: (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0,
                                                    right: 0)
        self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets(top: self.topLayoutGuide.length,
                                                    left: 0,
                                                    bottom: self.bottomLayoutGuide.length,
                                                    right: 0)
        self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
        
    }
    @objc func orientationChanged(_ notification: Notification) {
        self.layoutSubviews()
    }
    
    @objc func scrollViewTapped(_ gr: UIGestureRecognizer) {
        text.resignFirstResponder()
        subtitle.resignFirstResponder()
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.contentInsetAdjustmentBehavior = .never
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged(_:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        self.title = "CRToastSwift"
        debugStar.image = UIBezierPath.star(size: 30).strokeImage(with: UIColor.red)
    }
    
    func layoutSubviews() {
        self.scrollView.contentInset = UIEdgeInsets(top: self.topLayoutGuide.length,
                                                    left: 0,
                                                    bottom: self.bottomLayoutGuide.length,
                                                    right: 0)
        self.updateDuration(duration)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.layoutSubviews()
    }
    
    override var prefersStatusBarHidden: Bool { return self.statusBarVisibleEnabled == nil ? false : self.statusBarVisibleEnabled.isOn }
    
    @IBAction func updateDuration(_ sender: UISlider) {
        durationLbl.text = NSString(format: "%.1f seconds", duration.value) as String
    }
    @IBAction func updatePadding(_ sender: UISlider) {
        paddingLbl.text = NSString(format: "%d", Int(round(padding.value))) as String
    }
    @IBAction func updateTint(_ sender: UISlider) {
        imageTintEnabled.onTintColor = UIColor(hue: CGFloat(self.imageTint?.value ?? 0), saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    @IBAction func updateStatusBar(_ sender: UISwitch) {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    @IBAction func updateNavBar(_ sender: UISwitch) {
        self.navigationController?.setNavigationBarHidden(!sender.isOn, animated: true)
    }
    
    // MARK: -
    @IBAction func showNotification(_ sender: Any) {
        CRToastManager.showNotification(with: self.options(),
                                        appearance: {
                                            print("Appeared")
        }, completion: {
            print("Completed")
        })
    }
    
    // for debug purposes
    @IBAction func printIdentifiers(_ sender: Any) {
        print(CRToastManager.notificationIdentifiersInQueue())
    }
    
    @IBAction func dismiss(_ sender: Any) {
        CRToastManager.dismissNotification(animated: true)
    }
    
    // MARK: -
    func CRToastAnimationType(from :UISegmentedControl) -> CRToastAnimationType {
        switch from.selectedSegmentIndex {
        case 0:
            return .linear
        case 1:
            return .spring
        case 3:
            return .dynamic([imageEnabled,imageTint,statusBarVisibleLbl])
        default:
            return .gravity
        }
    }
    
    func CRToastViewAlignment(from :UISegmentedControl) -> CRToastAccessoryViewAlignment {
        let alignment : CRToastAccessoryViewAlignment
        switch from.selectedSegmentIndex {
        case 0: alignment = .left; break
        case 1: alignment = .center; break
        case 2: alignment = .right; break
        default: alignment = .left; break
        }
        
        return alignment
    }
    
    func textAlignment() -> NSTextAlignment {
        let selected = self.notificationTextAlignment.selectedSegmentIndex
        switch selected {
        case 0:
            return .left
        case 1:
            return .center
        default:
            return .right
        }
    }
    
    func subititleAlignment() -> NSTextAlignment {
        let selected = self.subtitleTextAlignment.selectedSegmentIndex
        switch selected {
        case 0:
            return .left
        case 1:
            return .center
        default:
            return .right
        }
    }
    
    func options() -> [CRToastOptionKey:Any] {
        var options : [CRToastOptionKey:Any] = [
            .type : self.coverNavBarEnabled.isOn ? CRToastType.navigationBar : CRToastType.statusBar,
            .presentationType : self.slideOverEnabled.isOn ? CRToastPresentationType.cover : CRToastPresentationType.push,
            .underStatusBar : self.statusBarVisibleEnabled.isOn,
            .text : self.text.text ?? "",
            .textAlignment : self.textAlignment(),
            .timeInterval : Double(self.duration.value),
            .animationInType : CRToastAnimationType(from: self.inAnimationType),
            .animationOutType : CRToastAnimationType(from: self.outAnimationType),
            .animationInDirection : CRToastAnimationDirection(rawValue: self.segFromDirection.selectedSegmentIndex) ?? .left,
            .animationOutDirection : CRToastAnimationDirection(rawValue: self.segToDirection.selectedSegmentIndex) ?? .right,
            .preferredPadding: self.padding.value
        ]
        
        if self.imageEnabled.isOn {
            options[.image] = UIImage(named: "alert_icon.png")!
            options[.imageAlignment] = CRToastViewAlignment(from: self.imageAlignment)
        }
        
        if self.imageTintEnabled.isOn {
            options[.imageTint] = UIColor(hue: CGFloat(self.imageTint?.value ?? 0), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        }
        
        if self.activityIndicatorEnabled.isOn {
            options[.showActivityIndicator] = true
            options[.activityIndicatorAlignment] = CRToastViewAlignment(from: self.activityIndicatorAlignment)
        }
        
        if self.forceUserInteractionEnabled.isOn {
            options[.forceUserInteraction] = true
        }
        
        if text.text?.count ?? 0 > 0 {
            options[.identifier] = text.text
        }
        
        if subtitle.text?.count ?? 0 > 0 {
            options[.subtitleText] = subtitle.text
            options[.subtitleTextAlignment] = self.subititleAlignment()
        }
        
        if dismissWithTapEnabled.isOn {
            options[.interactionResponders] = [
                CRToastInteractionResponder.interactionResponder(withInteractionType: .tap,
                                                                 automaticallyDismiss: true,
                                                                 block: { (type) in
                                                                    print("dismissed with \(type.asString)")
                })
            ] as [CRToastInteractionResponder]
        }
        
        return options
    }
}

