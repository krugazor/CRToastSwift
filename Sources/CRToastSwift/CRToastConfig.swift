import UIKit

func className(for obj: Any) -> String {
    return String(describing: type(of: obj))
}

/**
 CRToastInteractionType defines the types of interactions that can be injected into a CRToastIneractionResponder.
 */
public struct CRToastInteractionType : OptionSet {
    public let rawValue: Int
    
    public init(rawValue v: Int) {
        rawValue = v
    }
    
    public static let swipeUp                        = CRToastInteractionType(rawValue: 1 << 0)
    public static let swipeLeft                      = CRToastInteractionType(rawValue: 1 << 1)
    public static let swipeDown                      = CRToastInteractionType(rawValue: 1 << 2)
    public static let swipeRight                     = CRToastInteractionType(rawValue: 1 << 3)
    public static let tapOnce                        = CRToastInteractionType(rawValue: 1 << 4)
    public static let tapTwice                       = CRToastInteractionType(rawValue: 1 << 5)
    public static let twoFingerTapOnce               = CRToastInteractionType(rawValue: 1 << 6)
    public static let twoFingerTapTwice              = CRToastInteractionType(rawValue: 1 << 7)
    
    //An interaction responder with a CRToastInteractionTypeSwipe interaction type will fire on all swipe interactions
    public static let swipe:CRToastInteractionType   = [.swipeUp,
                                                 .swipeLeft,
                                                 .swipeDown,
                                                 .swipeRight]
    
    //An interaction responder with a CRToastInteractionTypeTap interaction type will fire on all tap interactions
    public static let tap:CRToastInteractionType     = [.tapOnce,
                                                 .tapTwice,
                                                 .twoFingerTapOnce,
                                                 .twoFingerTapTwice]
    
    //An interaction responder with a CRToastInteractionTypeAll interaction type will fire on all swipe and tap interactions
    public static let all:CRToastInteractionType     = [.swipe,.tap]
}

public extension CRToastInteractionType {
    var asString : String {
        switch self {
        case .swipeUp:
            return "CRToastInteractionTypeSwipeUp"
        case .swipeLeft:
            return "CRToastInteractionTypeSwipeLeft"
        case .swipeDown:
            return "CRToastInteractionTypeSwipeDown"
        case .swipeRight:
            return "CRToastInteractionTypeSwipeRight"
        case .tapOnce:
            return "CRToastInteractionTypeTapOnce"
        case .tapTwice:
            return "CRToastInteractionTypeTapTwice"
        case .twoFingerTapOnce:
            return "CRToastInteractionTypeTwoFingerTapOnce"
        case .twoFingerTapTwice:
            return "CRToastInteractionTypeTwoFingerTapTwice"
        case .swipe:
            return "CRToastInteractionTypeSwipe"
        case .tap:
            return "CRToastInteractionTypeTap"
        case .all:
            return "CRToastInteractionTypeAll"
        default:
            return "Unknown"
        }
    }
    
    var isGeneric : Bool { return self == .swipe || self == .tap || self == .all }
    var isSwipe : Bool { return (self.rawValue & CRToastInteractionType.swipe.rawValue) != 0 }
    var isTap : Bool { return (self.rawValue & CRToastInteractionType.tap.rawValue) != 0 }
}

///--------------------
/// @name Notification Option Types
///--------------------

/**
 `CRToastType` defines the height of the notification. `CRToastTypeStatusBar` covers the status bar, `CRToastTypeNavigationBar` covers the status bar
 and navigation bar
 */
public enum CRToastType {
    case statusBar
    case navigationBar
    case custom
}

/**
 `CRToastPresentationType` defines whether a notification will cover the contents of the status/navigation bar or whether the content will be pushed
 out by the notification.
 */
public enum CRToastPresentationType {
    case cover
    case push
}

/**
 `CRToastAnimationDirection` defines the direction of the notification. A direction can be specified for both notification entrance and exit.
 */
public enum CRToastAnimationDirection : Int {
    case top
    case bottom
    case left
    case right
    
    public var isVertical:Bool {
        return self == .bottom || self == .top
    }
}

/**
 `CRToastAnimationType` defines the timing function used for the notification presentation.
 */
public enum CRToastAnimationType : Equatable {
    case linear
    case spring
    case gravity
    case dynamic([UIView])
}

/**
 `CRToastState` defines the current state of the CRToast. Used for internal state management in the manager
 */
public enum CRToastState {
    case waiting
    case entering
    case displaying
    case exiting
    case completed
}

/**
 `CRToastImageAlignment` defines the alignment of the image given to the CRToast.
 */
public enum CRToastAccessoryViewAlignment {
    case left
    case center
    case right
}


// MARK: Options
public enum CRToastOptionKey : String {
    ///--------------------
    /// @name Option Keys
    ///--------------------
    
    /**
     These are the keys that define the options that can be set for a notifaction. All primitive types mentioned should
     be wrapped as `NSNumber`s or `NSValue`s
     */
    
    /**
     The notification type for the notification. Expects type `CRToastType`.
     */
    case type = "kCRToastNotificationTypeKey"
    
    /**
     The preferred height for the notificaiton, this will only be used for notifications with CRToastTypeCustom set for kCRToastNotificationTypeKey
     */
    case preferredHeight = "kCRToastNotificationPreferredHeightKey"
    
    /**
     The general preferred padding for the notification.
     */
    case preferredPadding = "kCRToastNotificationPreferredPaddingKey"
    
    /**
     The presentation type for the notification. Expects type `CRToastPresentationType`.
     */
    case presentationType = "kCRToastNotificationPresentationTypeKey"
    
    /**
     Indicates whether the notification should slide under the staus bar, leaving it visible or not.
     Making this YES with `kCRToastNotificationTypeKey` set to `CRToastTypeStatusBar` isn't sensible and will look
     odd. Expects type `BOOL`.
     */
    case underStatusBar = "kCRToastUnderStatusBarKey"
    
    /**
     Keep toast within navigation bar border.
     The standard navigation bar has a thin border on the bottom. Animations are
     improved when the toast is within the border. Customized bars without the border
     should have this set to NO.
     Expects type `BOOL`. Defaults to YES.
     */
    case keepNavigationBarBorder = "kCRToastKeepNavigationBarBorderKey"
    
    /**
     The animation in type for the notification. Expects type `CRToastAnimationType`.
     */
    case animationInType = "kCRToastAnimationInTypeKey"
    
    /**
     The animation out type for the notification. Expects type `CRToastAnimationType`.
     */
    case animationOutType = "kCRToastAnimationOutTypeKey"
    
    /**
     The animation in direction for the notification. Expects type `CRToastAnimationDirection`.
     */
    case animationInDirection = "kCRToastAnimationInDirectionKey"
    
    /**
     The animation out direction for the notification. Expects type `CRToastAnimationDirection`.
     */
    case animationOutDirection = "kCRToastAnimationOutDirectionKey"
    
    /**
     The animation in time interval for the notification. Expects type `NSTimeInterval`.
     */
    case animationInTimeInterval = "kCRToastAnimationInTimeIntervalKey"
    
    /**
     The notification presentation timeinterval of type for the notification. This is how long the notification
     will be on screen after its presentation but before its dismissal. Expects type `NSTimeInterval`.
     */
    case timeInterval = "kCRToastTimeIntervalKey"
    
    /**
     The animation out timeinterval for the notification. Expects type `NSTimeInterval`.
     */
    case animationOutTimeInterval = "kCRToastAnimationOutTimeIntervalKey"
    
    /**
     The spring damping coefficient to be used when `kCRToastAnimationInTypeKey` or `kCRToastAnimationOutTypeKey` is set to
     `CRToastAnimationTypeSpring`. Currently you can't define separate damping for in and out. Expects type `CGFloat`.
     */
    case animationSpringDamping = "kCRToastAnimationSpringDampingKey"
    
    /**
     The initial velocity coefficient to be used when `kCRToastAnimationInTypeKey` or `kCRToastAnimationOutTypeKey` is set to
     `CRToastAnimationTypeSpring`. Currently you can't define initial velocity for in and out. Expects type `CGFloat`.
     */
    case animationSpringInitialVelocity = "kCRToastAnimationSpringInitialVelocityKey"
    
    /**
     The gravity magnitude coefficient to be used when `kCRToastAnimationInTypeKey` or `kCRToastAnimationOutTypeKey` is set to
     `CRToastAnimationTypeGravity`. Currently you can't define gravity magnitude for in and out. Expects type `CGFloat`.
     */
    case animationGravityMagnitude = "kCRToastAnimationGravityMagnitudeKey"
    
    /**
     The main text to be shown in the notification. Expects type `NSString`.
     */
    case text = "kCRToastTextKey"
    
    /**
     The font to be used for the `kCRToastTextKey` value . Expects type `UIFont`.
     */
    case font = "kCRToastFontKey"
    
    /**
     The text color to be used for the `kCRToastTextKey` value . Expects type `UIColor`.
     */
    case textColor = "kCRToastTextColorKey"
    
    /**
     The text alignment to be used for the `kCRToastTextKey` value . Expects type `NSTextAlignment`.
     */
    case textAlignment = "kCRToastTextAlignmentKey"
    
    /**
     The shadow color to be used for the `kCRToastTextKey` value . Expects type `UIColor`.
     */
    case textShadowColor = "kCRToastTextShadowColorKey"
    
    /**
     The shadow offset to be used for the `kCRToastTextKey` value . Expects type `CGSize`.
     */
    case textShadowOffset = "kCRToastTextShadowOffsetKey"
    
    /**
     The max number of lines to be used for the `kCRToastTextKey` value . Expects type `NSInteger`.
     */
    case textMaxNumberOfLines = "kCRToastTextMaxNumberOfLinesKey"
    
    /**
     The subtitle text to be shown in the notification. Expects type `NSString`.
     */
    case subtitleText = "kCRToastSubtitleTextKey"
    
    /**
     The font to be used for the `kCRToastSubtitleTextKey` value . Expects type `UIFont`.
     */
    case subtitleFont = "kCRToastSubtitleFontKey"
    
    /**
     The text color to be used for the `kCRToastSubtitleTextKey` value . Expects type `UIColor`.
     */
    case subtitleTextColor = "kCRToastSubtitleTextColorKey"
    
    /**
     The text alignment to be used for the `kCRToastSubtitleTextKey` value . Expects type `NSTextAlignment`.
     */
    case subtitleTextAlignment = "kCRToastSubtitleTextAlignmentKey"
    
    /**
     The shadow color to be used for the `kCRToastSubtitleTextKey` value . Expects type `UIColor`.
     */
    case subtitleTextShadowColor = "kCRToastSubtitleTextShadowColorKey"
    
    /**
     The shadow offset to be used for the `kCRToastSubtitleTextKey` value . Expects type `NSInteger`.
     */
    case subtitleTextShadowOffset = "kCRToastSubtitleTextShadowOffsetKey"
    
    /**
     The max number of lines to be used for the `kCRToastSubtitleTextKey` value . Expects type `NSInteger`.
     */
    case subtitleTextMaxNumberOfLines = "kCRToastSubtitleTextMaxNumberOfLinesKey"
    
    /**
     The status bar style for the navigation bar.  Expects type `UIStatusBarStyle`.
     */
    case statusBarStyle = "kCRToastStatusBarStyleKey"
    
    /**
     The background color for the notification. Expects type `UIColor`.
     */
    case backgroundColor = "kCRToastBackgroundColorKey"
    
    /**
     Custom view used as the background of the notification
     */
    case backgroundView = "kCRToastBackgroundViewKey"
    
    /**
     The image to be shown on the left side of the notification. Expects type `UIImage`.
     */
    case image = "kCRToastImageKey"
    
    /**
     The image content mode to use for `kCRToastImageKey` image. Exptects type `UIViewContentMode`
     */
    case imageContentMode = "kCRToastImageContentModeKey"
    
    /**
     The image alignment to use. Expects type `CRToastAccessoryViewAlignment`.
     */
    case imageAlignment = "kCRToastImageAlignmentKey"
    
    /**
     The `UIColor` to tint the image provided. If supplied, `imageWithRenderingMode:` is used with `AlwaysTemplate`
     */
    case imageTint = "kCRToastImageTintKey"
    
    /**
     BOOL setting whether the CRToast should show a loading indicator in the left image location.
     */
    case showActivityIndicator = "kCRToastShowActivityIndicatorKey"
    
    /**
     The activity indicator view style. Expects type `UIActivityIndicatorViewStyle`
     */
    case activityIndicatorViewStyle = "kCRToastActivityIndicatorViewStyleKey"
    
    /**
     The activity indicator alignment to use. Expects type `CRToastAccessoryViewAlignment`.
     */
    case activityIndicatorAlignment = "kCRToastActivityIndicatorAlignmentKey"
    
    /**
     An Array of Interaction Responders for the Notification. Expects type `NSArray` full of `CRToastInteractionResponders`
     */
    case interactionResponders = "kCRToastInteractionRespondersKey"
    
    /**
     BOOL setting whether the CRToast should force the user to interact with it, ignoring the `kCRToastTimeIntervalKey` key
     */
    case forceUserInteraction = "kCRToastForceUserInteractionKey"
    
    /**
     An BOOL setting whether the CRToast's should autorotate. Expects type `BOOL` defaults to `YES`
     */
    case autorotate = "kCRToastAutorotateKey"
    
    /**
     Key for the Identifier for a notification.
     */
    case identifier = "kCRToastIdentifierKey"
    
    /**
     A BOOL setting whether the CRToast's should capture the screen behind the default UIWindow. Expects type `BOOL` defaults to `YES`
     */
    case captureDefaultWindow = "kCRToastCaptureDefaultWindowKey"
    
    case springDamping = "kCRToastSpringDampingKey"
    case springInitialVelocity  = "kCRToastSpringInitialVelocityKey"
    case gravityMagnitude = "kCRToastGravityMagnitude"
    
}

// MARK: Options defaults
public struct CROptions {
    public var toastType :CRToastType = .statusBar
    public var preferredHeight:CGFloat = 70
    public var preferredPadding:CGFloat = 0
    public var presentationType:CRToastPresentationType = .push;
    public var underStatusBar:Bool = false
    public var keepNavigationBarBorder:Bool = true;
    public var identifier:String? = nil
    
    public var animationTypeIn :CRToastAnimationType = .linear
    public var animationTypeOut :CRToastAnimationType = .linear
    public var animationInDirection :CRToastAnimationDirection = .top
    public var animationOutDirection :CRToastAnimationDirection = .bottom
    public var animateInTimeInterval :TimeInterval = 0.4
    public var animateOutTimeInterval :TimeInterval = 0.4
    public var timeInterval :TimeInterval = 2.0
    
    public var springDamping :CGFloat = 0.6
    public var springInitialVelocity :CGFloat = 1.0
    public var gravityMagnitude :CGFloat = 1.0
    
    public var text :String = ""
    public var font :UIFont = UIFont.systemFont(ofSize: 12.0)
    public var textColor :UIColor = UIColor.white
    public var textAlignment :NSTextAlignment = .center
    public var textShadowColor :UIColor? = nil
    public var textShadowOffset:CGSize = CGSize.zero
    public var textMaxNumberOfLines :NSInteger = 0
    
    public var subtitleText :String? = nil
    public var subtitleFont :UIFont = UIFont.systemFont(ofSize: 12.0)
    public var subtitleTextColor :UIColor = UIColor.white
    public var subtitleTextAlignment :NSTextAlignment = .center
    public var subtitleTextShadowColor :UIColor? = nil
    public var subtitleTextShadowOffset :CGSize = CGSize.zero;
    public var subtitleTextMaxNumberOfLines:Int = 0;
    public var statusBarStyle :UIStatusBarStyle = .default
    
    public var backgroundColor :UIColor
    public var backgroundView :UIView? = nil
    public var image :UIImage? = nil
    public var imageContentMode :UIView.ContentMode = .center
    public var imageAlignment :CRToastAccessoryViewAlignment = .left
    public var imageTint :UIColor? = nil
    public var showActivityIndicator :Bool = false
    public var activityIndicatorViewStyle :UIActivityIndicatorView.Style = .white
    public var activityIndicatorAlignment :CRToastAccessoryViewAlignment = .left
    
    public var interactionResponders :[CRToastInteractionResponder] = []
    public var forceUserInteraction :Bool = false
    
    public var autoRotate :Bool = true
    
    public var captureWindow :Bool = false

    public var toastKeyClassMap : [CRToastOptionKey:Any.Type]
    
    fileprivate init() {
        if let d = UIApplication.shared.delegate?.window??.tintColor {
            backgroundColor = d
        } else {
            backgroundColor = UIColor.red
        }
        
        toastKeyClassMap = [
            .type:CRToastType.self,
            .preferredHeight:CGFloat.self,
            .preferredPadding:Float.self,
            .presentationType:CRToastPresentationType.self,
            .underStatusBar:Bool.self,
            .keepNavigationBarBorder:Bool.self,
            .identifier:String.self,
            
            .animationInType:CRToastAnimationType.self,
            .animationOutType:CRToastAnimationType.self,
            .animationInDirection:CRToastAnimationDirection.self,
            .animationOutDirection:CRToastAnimationDirection.self,
            .animationInTimeInterval:TimeInterval.self,
            .animationOutTimeInterval:TimeInterval.self,
            .timeInterval:TimeInterval.self,
            
            .springDamping:CGFloat.self,
            .springInitialVelocity:CGFloat.self,
            .gravityMagnitude:CGFloat.self,
            
            .text:String.self,
            .font:UIFont.self,
            .textColor:UIColor.self,
            .textAlignment:NSTextAlignment.self,
            .textShadowColor:UIColor?.self,
            .textShadowOffset:CGSize.self,
            .textMaxNumberOfLines:NSInteger.self,
            
            .subtitleText:String.self,
            .subtitleFont:UIFont.self,
            .subtitleTextColor:UIColor?.self,
            .subtitleTextAlignment:NSTextAlignment.self,
            .subtitleTextShadowColor:UIColor?.self,
            .subtitleTextShadowOffset:CGSize.self,
            .subtitleTextMaxNumberOfLines:Int.self,
            .statusBarStyle:UIStatusBarStyle.self,
            
            .backgroundColor:UIColor.self,
            .backgroundView :UIView.self,
            .image:UIImage?.self,
            .imageContentMode:UIView.ContentMode.self,
            .imageAlignment:CRToastAccessoryViewAlignment.self,
            .imageTint:UIColor.self,
            .showActivityIndicator:Bool.self,
            .activityIndicatorViewStyle:UIActivityIndicatorView.Style.self,
            .activityIndicatorAlignment:CRToastAccessoryViewAlignment.self,
            
            .interactionResponders :[CRToastInteractionResponder].self,
            .forceUserInteraction:Bool.self,
            
            .autorotate:Bool.self,
            
            .captureDefaultWindow:Bool.self,
        ]
    }
    
    private static var _default : CROptions? = nil
    public static var `default` : CROptions {
        if let s = _default { return s }
        else {
            let s = CROptions()
            _default = s
            return s
        }
    }
    
    public init(options: [CRToastOptionKey:Any]) {
        self.init()
        /*
        // useful for obc type checking, less so in swift
        let cleanOptions = options.filter { (arg0) -> Bool in
            
            let (key, value) = arg0
            let inspection = Mirror(reflecting: value)
            
            return type(of: value) == toastKeyClassMap[key]
        }
        */
        
        let cleanOptions = options
        if let v = cleanOptions[.type] as? CRToastType { toastType = v }
        if let v = cleanOptions[.preferredHeight] as? CGFloat { preferredHeight = v }
        if let v = cleanOptions[.preferredPadding] as? Float { preferredPadding = CGFloat(v) } // UISlider gives FLOAT
        if let v = cleanOptions[.presentationType] as? CRToastPresentationType { presentationType = v }
        if let v = cleanOptions[.underStatusBar] as? Bool { underStatusBar = v }
        if let v = cleanOptions[.keepNavigationBarBorder] as? Bool { keepNavigationBarBorder = v }
        if let v = cleanOptions[.identifier] as? String { identifier = v }
        
        if let v = cleanOptions[.animationInType] as? CRToastAnimationType { animationTypeIn = v }
        if let v = cleanOptions[.animationOutType] as? CRToastAnimationType { animationTypeOut = v }
        if let v = cleanOptions[.animationInDirection] as? CRToastAnimationDirection { animationInDirection = v }
        if let v = cleanOptions[.animationOutDirection] as? CRToastAnimationDirection { animationOutDirection = v }
        if let v = cleanOptions[.animationInTimeInterval] as? TimeInterval { animateInTimeInterval = v }
        if let v = cleanOptions[.animationOutTimeInterval] as? TimeInterval { animateOutTimeInterval = v }
        if let v = cleanOptions[.timeInterval] as? TimeInterval { timeInterval = v }
        
        if let v = cleanOptions[.springDamping] as? CGFloat { springDamping = v }
        if let v = cleanOptions[.springInitialVelocity] as? CGFloat { springInitialVelocity = v }
        if let v = cleanOptions[.gravityMagnitude] as? CGFloat { gravityMagnitude = v }
        
        if let v = cleanOptions[.text] as? String { text = v }
        if let v = cleanOptions[.font] as? UIFont { font = v }
        if let v = cleanOptions[.textColor] as? UIColor { textColor = v }
        if let v = cleanOptions[.textAlignment] as? NSTextAlignment { textAlignment = v }
        if let v = cleanOptions[.textShadowColor] as? UIColor { textShadowColor = v }
        if let v = cleanOptions[.textShadowOffset] as? CGSize { textShadowOffset = v }
        if let v = cleanOptions[.textMaxNumberOfLines] as? NSInteger { textMaxNumberOfLines = v }
        
        if let v = cleanOptions[.subtitleText] as? String { subtitleText = v }
        if let v = cleanOptions[.subtitleFont] as? UIFont { subtitleFont = v }
        if let v = cleanOptions[.subtitleTextColor] as? UIColor { subtitleTextColor = v }
        if let v = cleanOptions[.subtitleTextAlignment] as? NSTextAlignment { subtitleTextAlignment = v }
        if let v = cleanOptions[.subtitleTextShadowColor] as? UIColor { subtitleTextShadowColor = v }
        if let v = cleanOptions[.subtitleTextShadowOffset] as? CGSize { subtitleTextShadowOffset = v }
        if let v = cleanOptions[.subtitleTextMaxNumberOfLines] as? Int { subtitleTextMaxNumberOfLines = v }
        if let v = cleanOptions[.statusBarStyle] as? UIStatusBarStyle { statusBarStyle = v }
        
        if let v = cleanOptions[.backgroundColor] as? UIColor { backgroundColor = v }
        if let v = cleanOptions[.backgroundView ] as? UIView { backgroundView  = v }
        if let v = cleanOptions[.image] as? UIImage? { image = v }
        if let v = cleanOptions[.imageContentMode] as? UIView.ContentMode { imageContentMode = v }
        if let v = cleanOptions[.imageAlignment] as? CRToastAccessoryViewAlignment { imageAlignment = v }
        if let v = cleanOptions[.imageTint] as? UIColor? { imageTint = v }
        if let v = cleanOptions[.showActivityIndicator] as? Bool { showActivityIndicator = v }
        if let v = cleanOptions[.activityIndicatorViewStyle] as? UIActivityIndicatorView.Style { activityIndicatorViewStyle = v }
        if let v = cleanOptions[.activityIndicatorAlignment] as? CRToastAccessoryViewAlignment { activityIndicatorAlignment = v }
        
        if let v = cleanOptions[.interactionResponders ] as? [CRToastInteractionResponder] { interactionResponders  = v }
        if let v = cleanOptions[.forceUserInteraction] as? Bool { forceUserInteraction = v }
        
        if let v = cleanOptions[.autorotate] as? Bool { autoRotate = v }
        
        if let v = cleanOptions[.captureDefaultWindow] as? Bool { captureWindow = v }
    }
    
    
}

public typealias CRToastInteractionResponderBlock = (_ interactionType: CRToastInteractionType)->Void
public class CRToastInteractionResponder : NSObject {
    private var interactionType:CRToastInteractionType = CRToastInteractionType.tap
    private var automaticallyDismiss:Bool = true
    private var block:CRToastInteractionResponderBlock = { interactionType in return }
    public static func interactionResponder(withInteractionType: CRToastInteractionType, automaticallyDismiss: Bool, block: @escaping CRToastInteractionResponderBlock) -> CRToastInteractionResponder {
        let responder = CRToastInteractionResponder()
        responder.interactionType = withInteractionType
        responder.automaticallyDismiss = automaticallyDismiss
        responder.block = block
        return responder
    }
}

public class CRToast : NSObject, UIGestureRecognizerDelegate {
    public var uuid : UUID = UUID()
    public var state : CRToastState = .waiting
  
    //Top Level Properties
    public var options : CROptions = CROptions.default
    public var completion : ()->Void = { return }
    public var appearance : (()->Void)? = { return }
    
    public func setOptions(_ options: CROptions) {
        self.options = options
        self.warnAboutSensibility()
    }
    
    public func setOptions(_ options: [CRToastOptionKey:Any]) {
        self.options = CROptions(options: options)
        self.warnAboutSensibility()
    }
    
    //Interactions
    public var gestureRecognizers : [UIGestureRecognizer] = []
    
    //Autorotate
    public var autorotate : Bool {
        get {
            return options.autoRotate
        }
        set {
            options.autoRotate = newValue
        }
    }
    
    
    //Views and Layout Data
    fileprivate var _privateNotificationView : UIView?
    fileprivate var privateNotificationView : UIView {
        if let v = _privateNotificationView { return v }
        
        let vs = CRNotificationViewSize(toastType,preferredHeight)
        let v = CRToastView(frame: CGRect(x: 0, y: 0, width: vs.width, height: vs.height))
        _privateNotificationView = v
        return v
    }
    public var notificationView:UIView {
        return self.privateNotificationView
    }
    public var notificationViewAnimationFrame1:CGRect {
        return CRNotificationViewFrame(self.toastType, self.animationInDirection, self.preferredHeight)
    }
    public var notificationViewAnimationFrame2:CGRect {
        return CRNotificationViewFrame(self.toastType, self.animationOutDirection, self.preferredHeight);
    }
 
    fileprivate var _privateStatusBarView : UIView?
    fileprivate var privateStatusBarView : UIView {
        if let v = _privateStatusBarView { return v }
        
        let v = UIView(frame: self.statusBarViewAnimationFrame1)
        if self.snapshotWindow {
            DispatchQueue.main.async {
                if let sv = CRStatusBarSnapShotView(self.underStatusBar) { v.addSubview(sv) }
            }
        }
        v.clipsToBounds = true
        _privateStatusBarView = v
        return v
    }
    public var statusBarView:UIView { return self.privateStatusBarView }
    public var statusBarViewAnimationFrame1:CGRect {
        return CRStatusBarViewFrame(self.toastType, self.animationInDirection, self.preferredHeight);
    }
    public var statusBarViewAnimationFrame2:CGRect {
        return CRStatusBarViewFrame(self.toastType, self.animationOutDirection, self.preferredHeight);
    }
    public var animator:UIDynamicAnimator? = nil

    // options
    public var toastType:CRToastType { return options.toastType }
    public var preferredHeight:CGFloat { return options.preferredHeight }
    public var preferredPadding:CGFloat { return options.preferredPadding }
    public var presentationType:CRToastPresentationType { return options.presentationType }
    public var underStatusBar:Bool { return options.underStatusBar }
    public var keepNavigationBarBorder:Bool { return options.keepNavigationBarBorder }
    public var identifier:String? { return options.identifier }
    
    public var animationTypeIn:CRToastAnimationType { return options.animationTypeIn }
    public var animationTypeOut:CRToastAnimationType { return options.animationTypeOut }
    public var animationInDirection:CRToastAnimationDirection { return options.animationInDirection }
    public var animationOutDirection:CRToastAnimationDirection { return options.animationOutDirection }
    public var animateInTimeInterval:TimeInterval { return options.animateInTimeInterval }
    public var animateOutTimeInterval:TimeInterval { return options.animateOutTimeInterval }
    public var timeInterval:TimeInterval { return options.timeInterval }
    
    public var springDamping:CGFloat { return options.springDamping }
    public var springInitialVelocity:CGFloat { return options.springInitialVelocity }
    public var gravityMagnitude:CGFloat { return options.gravityMagnitude }
    
    public var text:String { return options.text }
    public var font:UIFont { return options.font }
    public var textColor:UIColor { return options.textColor }
    public var textAlignment:NSTextAlignment { return options.textAlignment }
    public var textShadowColor:UIColor? { return options.textShadowColor }
    public var textShadowOffset:CGSize { return options.textShadowOffset }
    public var textMaxNumberOfLines:NSInteger { return options.textMaxNumberOfLines }
    
    public var subtitleText:String? { return options.subtitleText }
    public var subtitleFont:UIFont { return options.subtitleFont }
    public var subtitleTextColor:UIColor { return options.subtitleTextColor }
    public var subtitleTextAlignment:NSTextAlignment { return options.subtitleTextAlignment }
    public var subtitleTextShadowColor:UIColor? { return options.subtitleTextShadowColor }
    public var subtitleTextShadowOffset:CGSize { return options.subtitleTextShadowOffset }
    public var subtitleTextMaxNumberOfLines:Int { return options.subtitleTextMaxNumberOfLines }
    public var statusBarStyle:UIStatusBarStyle { return options.statusBarStyle }
    
    public var backgroundColor:UIColor { return options.backgroundColor }
    public var backgroundView:UIView? { return options.backgroundView }
    public var image:UIImage? { return options.image }
    public var imageContentMode:UIView.ContentMode { return options.imageContentMode }
    public var imageAlignment:CRToastAccessoryViewAlignment { return options.imageAlignment }
    public var imageTint:UIColor? { return options.imageTint }
    public var showActivityIndicator:Bool { return options.showActivityIndicator }
    public var activityIndicatorViewStyle:UIActivityIndicatorView.Style { return options.activityIndicatorViewStyle }
    public var activityIndicatorAlignment:CRToastAccessoryViewAlignment { return options.activityIndicatorAlignment }
    
    public var interactionResponders:[CRToastInteractionResponder] { return options.interactionResponders }
    public var forceUserInteraction:Bool { return options.forceUserInteraction }
    
    public var captureWindow:Bool { return options.captureWindow }
    var snapshotWindow:Bool { return options.captureWindow }

    public var inGravityDirection:CGVector {
        let x = animationInDirection.isVertical ? 0.0 : (animationInDirection == .left ? 1 : -1)
        let y = x != 0 ? 0.0 : (animationInDirection == .top ? 1 : -1)
        return CGVector(dx: x, dy: y)
    }
    public var outGravityDirection:CGVector {
        let x = animationOutDirection.isVertical ? 0.0 : (animationOutDirection == .left ? -1 : 1)
        let y = x != 0 ? 0.0 : (animationOutDirection == .top ? -1 : 1)
        return CGVector(dx: x, dy: y)
    }
    
    let kCollisionTweak:CGFloat = 0.5
    public var inCollisionPoint1:CGPoint {
        let x:CGFloat
        let y:CGFloat
        let factor:CGFloat = presentationType == .cover ? 1 : 2
        let push = presentationType == .push
        switch animationInDirection {
        case .top:
            x = 0
            y = factor*(self.notificationViewAnimationFrame1.height)+(push ? -4*kCollisionTweak : kCollisionTweak)
        case .bottom:
            x = notificationViewAnimationFrame1.width
            y = -(factor-1)*notificationViewAnimationFrame1.height - (push ? -5*kCollisionTweak : kCollisionTweak)
        case .left:
            x = factor*(self.notificationViewAnimationFrame1.width)+(push ? -5*kCollisionTweak : 2*kCollisionTweak)
            y = notificationViewAnimationFrame1.height
        case .right:
            x = -(factor-1)*notificationViewAnimationFrame1.width - (push ? -5*kCollisionTweak : 2*kCollisionTweak)
            y = 0
        }
        
        return CGPoint(x: x,y: y)
    }
    public var inCollisionPoint2:CGPoint {
        let x:CGFloat
        let y:CGFloat
        let factor:CGFloat = presentationType == .cover ? 1 : 2
        let push = presentationType == .push
        switch animationInDirection {
        case .top:
            x = notificationViewAnimationFrame1.width
            y = factor*(self.notificationViewAnimationFrame1.height)+(push ? -4*kCollisionTweak : kCollisionTweak)
        case .bottom:
            x = 0
            y = -(factor-1)*notificationViewAnimationFrame1.height - (push ? -5*kCollisionTweak : kCollisionTweak)
        case .left:
            x = factor*(self.notificationViewAnimationFrame1.width)+(push ? -5*kCollisionTweak : 2*kCollisionTweak)
            y = 0
        case .right:
            x = -(factor-1)*notificationViewAnimationFrame1.width - (push ? -5*kCollisionTweak : 2*kCollisionTweak)
            y = notificationViewAnimationFrame1.height
        }
        
        return CGPoint(x: x,y: y)
    }
    public var outCollisionPoint1:CGPoint {
        let x:CGFloat
        let y:CGFloat
        switch animationOutDirection {
        case .top:
            x = notificationViewAnimationFrame1.width
            y = -self.notificationViewAnimationFrame1.height - kCollisionTweak
        case .bottom:
            x = 0
            y = 2*notificationViewAnimationFrame1.height + kCollisionTweak
        case .left:
            x = -notificationViewAnimationFrame1.width-kCollisionTweak
            y = 0
        case .right:
            x = 2*notificationViewAnimationFrame1.width + 2*kCollisionTweak
            y = notificationViewAnimationFrame1.height
        }
        
        return CGPoint(x: x,y: y)
    }
    public var outCollisionPoint2:CGPoint {
        let x:CGFloat
        let y:CGFloat
        switch animationOutDirection {
        case .top:
            x = 0
            y = -self.notificationViewAnimationFrame1.height - kCollisionTweak
        case .bottom:
            x = notificationViewAnimationFrame1.width
            y = 2*notificationViewAnimationFrame1.height + kCollisionTweak
        case .left:
            x = -notificationViewAnimationFrame1.width-kCollisionTweak
            y = notificationViewAnimationFrame1.height
        case .right:
            x = 2*notificationViewAnimationFrame1.width + 2*kCollisionTweak
            y = 0
        }
        
        return CGPoint(x: x,y: y)
    }
    
    func warnAboutSensibility() {
        if self.toastType == .statusBar {
            if self.underStatusBar {
                print("[CRToast] : WARNING - It is not sensible to have set kCRToastNotificationTypeKey to @(CRToastTypeStatusBar) while setting kCRToastUnderStatusBarKey to @(YES). I'll do what you ask, but it'll probably work weird")
            }
            if subtitleText != nil {
                print("[CRToast] : WARNING - It is not sensible to have set kCRToastNotificationTypeKey to @(CRToastTypeStatusBar) and configuring subtitle text to show. I'll do what you ask, but it'll probably work weird")
            }
        }
        
        if animationTypeIn == CRToastAnimationType.gravity && animateInTimeInterval != CROptions.default.animateInTimeInterval {
            print("[CRToast] : WARNING - It is not sensible to have set kCRToastAnimationInTypeKey to @(CRToastAnimationTypeGravity) and configure a kCRToastAnimationInTimeIntervalKey. Gravity and distance will be driving the in animation duration here. kCRToastAnimationGravityMagnitudeKey can be modified to change the in animation duration.")
        }
        
        if animationTypeOut == CRToastAnimationType.gravity && animateOutTimeInterval != CROptions.default.animateOutTimeInterval {
            print("[CRToast] : WARNING - It is not sensible to have set kCRToastAnimationOutTypeKey to @(CRToastAnimationTypeGravity) and configure a kCRToastAnimationOutTimeIntervalKey. Gravity and distance will be driving the in animation duration here. kCRToastAnimationGravityMagnitudeKey can be modified to change the in animation duration.")
        }
        
        if forceUserInteraction && gestureRecognizers.count == 0 {
            print("[CRToast] : WARNING - It is not sensible to have set kCRToastForceUserInteractionKey to @(YES) and not set any interaction responders. This notification can only be dismissed programmatically.")
        }
    }

    // MARK: Gestures
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    public func initiateAnimator(_ view: UIView) {
        self.animator = UIDynamicAnimator(referenceView: view)
        self.animator?.delegate = self
    }
    
    @objc public func swipeGestureRecognizerSwiped(_ gestureRecognizer: CRToastSwipeGestureRecognizer) {
        
    }
    @objc public func tapGestureRecognizerTapped(_ gestureRecognizer: CRToastTapGestureRecognizer) {
        
    }
}

extension CRToast : UIDynamicAnimatorDelegate {
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        // print("pause")
    }
}

// MARK: Utilities
func CRFrameAutoAdjustedForOrientation() -> Bool {
    return true // in swift, ios < 8 aren't supported
}

func CRUseSizeClass() -> Bool {
    return CRFrameAutoAdjustedForOrientation()
}

func CRHorizontalSizeClassRegular() -> Bool {
    return UIScreen.main.traitCollection.horizontalSizeClass == .regular
}

let CRNavigationBarDefaultHeight:CGFloat = 65.0
let CRNavigationBarDefaultHeightiPhoneLandscape:CGFloat = 53.0

func CRGetDeviceOrientation() -> UIInterfaceOrientation {
    return UIApplication.shared.statusBarOrientation
}

// Status bar
func CRGetStatusBarHeightForOrientation(_ orientation: UIInterfaceOrientation) -> CGFloat {
    let statusBarFrame = UIApplication.shared.statusBarFrame
    return statusBarFrame.height
}
func CRGetStatusBarWidthForOrientation(_ orientation: UIInterfaceOrientation) -> CGFloat {
    let statusBarFrameWidth = UIApplication.shared.keyWindow?.frame.width ?? UIApplication.shared.statusBarFrame.width
    return statusBarFrameWidth
}
func CRGetStatusBarWidth() -> CGFloat {
    return CRGetStatusBarWidthForOrientation(CRGetDeviceOrientation())
}
func CRGetStatusBarHeight() -> CGFloat {
    return CRGetStatusBarHeightForOrientation(CRGetDeviceOrientation())
}

// Navigation bar
// from https://stackoverflow.com/questions/11637709/get-the-current-displaying-uiviewcontroller-on-the-screen-in-appdelegate-m/42486823#42486823
extension UIWindow {
    /// Returns the currently visible view controller if any reachable within the window.
    public var visibleViewController: UIViewController? {
        return UIWindow.visibleViewController(from: rootViewController)
    }
    
    /// Recursively follows navigation controllers, tab bar controllers and modal presented view controllers starting
    /// from the given view controller to find the currently visible view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller to start the recursive search from.
    /// - Returns: The view controller that is most probably visible on screen right now.
    public static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        switch viewController {
        case let navigationController as UINavigationController:
            return UIWindow.visibleViewController(from: navigationController.visibleViewController ?? navigationController.topViewController)
            
        case let tabBarController as UITabBarController:
            return UIWindow.visibleViewController(from: tabBarController.selectedViewController)
            
        case let presentingViewController where viewController?.presentedViewController != nil:
            return UIWindow.visibleViewController(from: presentingViewController?.presentedViewController)
            
        default:
            return viewController
        }
    }
}
func CRGetNavigationBarHeightForOrientation(_ orientation: UIInterfaceOrientation) -> CGFloat {
    if let rootViewController = UIApplication.shared.keyWindow?.rootViewController, let visibleViewController = UIWindow.visibleViewController(from: rootViewController) {
        return visibleViewController.view.safeAreaInsets.top
    }
    
    let regularHorizontalSizeClass = CRHorizontalSizeClassRegular()
    
    if orientation.isPortrait || UI_USER_INTERFACE_IDIOM() == .pad || regularHorizontalSizeClass {
        return CRNavigationBarDefaultHeight
    } else {
        return CRNavigationBarDefaultHeightiPhoneLandscape
    }
}

// Notification view
func CRGetNotificationViewHeightForOrientation(_ type: CRToastType, _ preferredHeight: CGFloat, _ orientation: UIInterfaceOrientation) -> CGFloat {
    switch type {
    case .statusBar:
        return CRGetStatusBarHeightForOrientation(orientation)
    case .navigationBar:
        return CRGetNavigationBarHeightForOrientation(orientation)
    case .custom:
        return preferredHeight
    }
}

func CRGetNotificationViewHeight(_ type: CRToastType, _ preferredHeight: CGFloat) -> CGFloat {
    return CRGetNotificationViewHeightForOrientation(type, preferredHeight, CRGetDeviceOrientation())
}

func CRNotificationViewSizeForOrientation(_ type: CRToastType, _ preferredHeight: CGFloat, _ orientation: UIInterfaceOrientation) -> CGSize {
    return CGSize(width: CRGetStatusBarWidthForOrientation(orientation), height: CRGetNotificationViewHeightForOrientation(type, preferredHeight, orientation))
}
func CRNotificationViewSize(_ type: CRToastType, _ preferredHeight: CGFloat) -> CGSize {
    return CGSize(width: CRGetStatusBarWidth(), height: CRGetNotificationViewHeight(type, preferredHeight))
}

func CRNotificationViewFrame(_ type:CRToastType, _ direction: CRToastAnimationDirection, _ preferredNotificationHeight : CGFloat) -> CGRect {
    let x = direction == .left ? -CRGetStatusBarWidth() : (direction == .right ? CRGetStatusBarWidth() : 0)
    let y = direction == .top ? -CRGetNotificationViewHeight(type, preferredNotificationHeight) : (direction == .bottom ? CRGetNotificationViewHeight(type, preferredNotificationHeight) : 0)
    return CGRect(x: x, y: y, width: CRGetStatusBarWidth(), height: CRGetNotificationViewHeight(type, preferredNotificationHeight))
}
func CRStatusBarViewFrame(_ type:CRToastType, _ direction: CRToastAnimationDirection, _ preferredNotificationHeight : CGFloat) -> CGRect {
    let _direction : CRToastAnimationDirection
    switch direction {
    case .top:
        _direction = .bottom
    case .bottom:
        _direction = .top
    case .left:
        _direction = .right
    case .right:
        _direction = .left
    }
    return CRNotificationViewFrame(type, _direction, preferredNotificationHeight)
}

func CRGetNotificationContainerFrame(_ statusBarOrientation : UIInterfaceOrientation, _ notificationSize : CGSize) -> CGRect {
    var containerFrame = CGRect(x: 0, y: 0, width: notificationSize.width, height: notificationSize.height)
    
    if !CRFrameAutoAdjustedForOrientation() {
        switch statusBarOrientation {
        case .landscapeLeft:
            containerFrame = CGRect(x: 0, y: 0, width: notificationSize.height, height: notificationSize.width)
        case .landscapeRight:
            containerFrame = CGRect(x: UIScreen.main.bounds.width-notificationSize.height, y: 0, width: notificationSize.height, height: notificationSize.width)
        case .portraitUpsideDown:
            containerFrame = CGRect(x: 0, y: UIScreen.main.bounds.height-notificationSize.height, width: notificationSize.width, height: notificationSize.height);
        default:
            break
        }
    }
    
    return containerFrame
}

func CRStatusBarSnapShotView(_ underStatusBar: Bool) -> UIView? {
    return underStatusBar ? UIApplication.shared.keyWindow?.rootViewController?.view.snapshotView(afterScreenUpdates: true) : UIScreen.main.snapshotView(afterScreenUpdates: true)
}


// MARK: Gesture Recognizers

public class CRToastSwipeGestureRecognizer : UISwipeGestureRecognizer {
    public var automaticallyDismiss : Bool = true
    public var interactionType : CRToastInteractionType = .tap
    public var block : CRToastInteractionResponderBlock = { _ in return }
}

public class CRToastTapGestureRecognizer : UITapGestureRecognizer {
    public var automaticallyDismiss : Bool = true
    public var interactionType : CRToastInteractionType = .tap
    public var block : CRToastInteractionResponderBlock = { _ in return }
}
