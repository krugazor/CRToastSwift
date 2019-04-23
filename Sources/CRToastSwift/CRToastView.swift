import UIKit

let kCRStatusBarViewNoImageLeftContentInset : CGFloat = 10
let kCRStatusBarViewNoImageRightContentInset : CGFloat = 10

// UIApplication's statusBarFrame will return a height for the status bar that includes
// a 5 pixel vertical padding. This frame height is inappropriate to use when centering content
// vertically under the status bar. This adjustment is used to correct the frame height when centering
// content under the status bar.
let CRStatusBarViewUnderStatusBarYOffsetAdjustment : CGFloat = -5

func CRImageViewFrameXOffsetForAlignment( alignment: CRToastAccessoryViewAlignment, preferredPadding : CGFloat, contentSize: CGSize) -> CGFloat {
    let imageSize = contentSize.height
    var xOffset:CGFloat = 0
    
    if alignment == .left {
        xOffset = preferredPadding
    } else if alignment == .center {
        // Calculate mid point of contentSize, then offset for x for full image width
        // that way center of image will be center of content view
        xOffset = (contentSize.width / 2) - (imageSize / 2)
    } else if alignment == .right {
        xOffset = contentSize.width - preferredPadding - imageSize
    }
    return xOffset
}

func CRContentXOffsetForViewAlignmentAndWidth( imageAlignment: CRToastAccessoryViewAlignment, imageXOffset: CGFloat, imageWidth: CGFloat, preferredPadding: CGFloat) -> CGFloat {
    return ((imageWidth == 0 || imageAlignment != .left) ?
        kCRStatusBarViewNoImageLeftContentInset + preferredPadding :
        imageXOffset + imageWidth)
}

func CRToastWidthOfViewWithAlignment(height: CGFloat, showing: Bool, alignment: CRToastAccessoryViewAlignment, preferredPadding: CGFloat) -> CGFloat {
    return (!showing || alignment == .center) ?
        0 :
        preferredPadding + height + preferredPadding
}

/**
 Calculate the width of the view given all necessary values of the given `CRToastView`s properties
 
 @param fullContentWidth           full width of contentView to fill
 @param fullContentHeight          full height of the content view. It is assumed the image & activity indicators frame is a square with sides the length of the height of the contentView.
 @param preferredPadding           preferred padding to use to lay out the view.
 @param showingImage               @c YES if an image is being shown and should be accounted for. @c NO otherwise.
 @param imageAlignment             alignment of image. Only used if @c showingImage is set to @c YES
 @param showingActivityIndicator   @c YES if an activity indicator is being shown and should be accounted for. @c NO otherwise.
 @param activityIndicatorAlignment alignment of activity indicator. Only used if @c showingActivityIndicator is set to @c YES
 */
public func CRContentWidthForAccessoryViewsWithAlignments(fullContentWidth: CGFloat, fullContentHeight: CGFloat, preferredPadding: CGFloat, showingImage: Bool, imageAlignment: CRToastAccessoryViewAlignment, showingActivityIndicator: Bool, activityIndicatorAlignment: CRToastAccessoryViewAlignment) -> CGFloat {
    var width = fullContentWidth
    if (imageAlignment == activityIndicatorAlignment && showingActivityIndicator && showingImage) {
        return fullContentWidth
    }
    
    width -= CRToastWidthOfViewWithAlignment(height: fullContentHeight, showing: showingImage, alignment: imageAlignment, preferredPadding: preferredPadding)
    width -= CRToastWidthOfViewWithAlignment(height: fullContentHeight, showing: showingActivityIndicator, alignment: activityIndicatorAlignment, preferredPadding: preferredPadding)
    
    if (!showingImage && !showingActivityIndicator) {
        width -= (kCRStatusBarViewNoImageLeftContentInset + kCRStatusBarViewNoImageRightContentInset)
        width -= (preferredPadding + preferredPadding)
    }
    
    return width
}

func CRCenterXForActivityIndicatorWithAlignment(alignment: CRToastAccessoryViewAlignment, viewWidth: CGFloat, contentWidth: CGFloat, preferredPadding: CGFloat) -> CGFloat {
    var center:CGFloat = 0
    let offset = viewWidth / 2 + preferredPadding
    
    switch (alignment) {
    case .left:
        center = offset
        break
    case .center:
        center = (contentWidth / 2)
        break
    case .right:
        center = contentWidth - offset
        break
    }
    
    return center
}

public class CRToastView : UIView {
    public var imageView : UIImageView
    public var activityIndicator : UIActivityIndicatorView
    public var label : UILabel
    public var subtitleLabel : UILabel
    public var backgroundView : UIView?
    
    public var toast : CRToast? {
        didSet {
            if let toast = toast {
                label.text = toast.text
                label.font = toast.font
                label.textColor = toast.textColor
                label.textAlignment = toast.textAlignment
                label.numberOfLines = toast.textMaxNumberOfLines
                label.shadowOffset = toast.textShadowOffset
                label.shadowColor = toast.textShadowColor
                if (toast.subtitleText != nil) {
                    subtitleLabel.text = toast.subtitleText
                    subtitleLabel.font = toast.subtitleFont
                    subtitleLabel.textColor = toast.subtitleTextColor
                    subtitleLabel.textAlignment = toast.subtitleTextAlignment
                    subtitleLabel.numberOfLines = toast.subtitleTextMaxNumberOfLines
                    subtitleLabel.shadowOffset = toast.subtitleTextShadowOffset
                    subtitleLabel.shadowColor = toast.subtitleTextShadowColor
                }
                if let img = toast.imageTint {
                    imageView.image = toast.image?.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = img
                } else {
                    imageView.image = toast.image
                }
                imageView.contentMode = toast.imageContentMode
                activityIndicator.style = toast.activityIndicatorViewStyle
                self.backgroundColor = toast.backgroundColor
                
                if let bg = toast.backgroundView {
                    backgroundView = bg
                    if bg.superview == nil {
                        self.insertSubview(bg, at: 0)
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        imageView = UIImageView(frame: CGRect.zero)
        activityIndicator = UIActivityIndicatorView(style: .white)
        label = UILabel(frame: CGRect.zero)
        subtitleLabel = UILabel(frame: CGRect.zero)
        defer {
            self.isUserInteractionEnabled = true
            self.accessibilityLabel = className(for: self)
            self.autoresizingMask = .flexibleWidth
            
            imageView.isUserInteractionEnabled = false
            imageView.contentMode = .center
            self.addSubview(imageView)
            
            activityIndicator.isUserInteractionEnabled = false
            self.addSubview(activityIndicator)
            
            label.isUserInteractionEnabled = false
            self.addSubview(label)
            
            subtitleLabel.isUserInteractionEnabled = false
            self.addSubview(subtitleLabel)
            
            self.isAccessibilityElement = true
        }
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(frame: CGRect.zero)
        activityIndicator = UIActivityIndicatorView(style: .white)
        label = UILabel(frame: CGRect.zero)
        subtitleLabel = UILabel(frame: CGRect.zero)
        
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true
        self.accessibilityLabel = className(for: self)
        self.autoresizingMask = .flexibleWidth
        
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .center
        self.addSubview(imageView)
        
        activityIndicator.isUserInteractionEnabled = false
        self.addSubview(activityIndicator)
        
        label.isUserInteractionEnabled = false
        self.addSubview(label)
        
        subtitleLabel.isUserInteractionEnabled = false
        self.addSubview(subtitleLabel)
        
        self.isAccessibilityElement = true
    }
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        
        return false
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let toast = self.toast {
            var contentFrame = self.bounds
            let imageSize = self.imageView.image?.size ?? CGSize.zero
            let preferredPadding = toast.preferredPadding
            
            let statusBarYOffset = (toast.underStatusBar) ? (CRGetStatusBarHeight()+CRStatusBarViewUnderStatusBarYOffsetAdjustment) : 0
            contentFrame.size.height = contentFrame.height - statusBarYOffset
            
            self.backgroundView?.frame = self.bounds
            
            let imageXOffset = CRImageViewFrameXOffsetForAlignment(alignment: toast.imageAlignment, preferredPadding: preferredPadding, contentSize: contentFrame.size)
            self.imageView.frame = CGRect(x: imageXOffset,
                                          y: statusBarYOffset,
                                          width: imageSize.width == 0 ?
                                            0 :
                                            contentFrame.height,
                                          height: imageSize.height == 0 ?
                                                0 :
                                                contentFrame.height)
            let imageWidth = imageSize.width == 0 ? 0 : imageView.frame.maxX
            var x = CRContentXOffsetForViewAlignmentAndWidth(imageAlignment: toast.imageAlignment, imageXOffset: imageXOffset, imageWidth: imageWidth, preferredPadding: preferredPadding)
            
            if toast.showActivityIndicator {
                let centerX = CRCenterXForActivityIndicatorWithAlignment(alignment: toast.activityIndicatorAlignment, viewWidth: contentFrame.height, contentWidth: contentFrame.width, preferredPadding: preferredPadding)
                self.activityIndicator.center = CGPoint(x: centerX, y: contentFrame.midY+statusBarYOffset)
                self.activityIndicator.startAnimating()
                x = max(x, CRContentXOffsetForViewAlignmentAndWidth(imageAlignment: toast.activityIndicatorAlignment, imageXOffset: imageXOffset, imageWidth: contentFrame.height, preferredPadding: preferredPadding))
                self.bringSubviewToFront(activityIndicator)
            }
            
            let showingImage = imageSize.width > 0
            let width = CRContentWidthForAccessoryViewsWithAlignments(fullContentWidth: contentFrame.width,
                                                                      fullContentHeight: contentFrame.height,
                                                                      preferredPadding: preferredPadding,
                                                                      showingImage: showingImage,
                                                                      imageAlignment: toast.imageAlignment,
                                                                      showingActivityIndicator: toast.showActivityIndicator,
                                                                      activityIndicatorAlignment: toast.activityIndicatorAlignment)
            if toast.subtitleText == nil {
                self.label.frame = CGRect(x: x, y: statusBarYOffset, width: width, height: contentFrame.height)
            } else {
                let height = min(contentFrame.height,
                                 (toast.text as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                                       options: .usesLineFragmentOrigin,
                                                                       attributes: [NSAttributedString.Key.font: toast.font],
                                                                       context:nil).height)
                var subtitleHeight = (toast.subtitleText! as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                                                    options: .usesLineFragmentOrigin,
                                                                                    attributes: [NSAttributedString.Key.font: toast.subtitleFont],
                                                                                    context: nil).height
                if contentFrame.height-(height+subtitleHeight) < 5 {
                    subtitleHeight = contentFrame.height - height - 10
                }
                let offset = (contentFrame.height - (height+subtitleHeight))*0.5 + (hasTopNotch ? 4.0 : 0.0)
                
                self.label.frame = CGRect(x: x, y: offset+statusBarYOffset,
                                          width: contentFrame.width-x-kCRStatusBarViewNoImageRightContentInset,
                                          height: height)
                self.subtitleLabel.frame = CGRect(x: x, y: height+offset+statusBarYOffset,
                                                  width: contentFrame.width-x-kCRStatusBarViewNoImageRightContentInset,
                                                  height: subtitleHeight)
            }
            
            // Account for center alignment of text and an accessory view
            if (showingImage || toast.showActivityIndicator)
                && (toast.activityIndicatorAlignment == .center || toast.imageAlignment == .center)
                && toast.textAlignment == .center {
                let labelHeight = self.label.frame.height // Store labelHeight for resetting after calling sizeToFit
                self.label.sizeToFit() // By default our size is rather large so lets fix that for further calculations
                let subtitleLabelHeight = self.subtitleLabel.frame.height // ditto
                self.subtitleLabel.sizeToFit() // ditto
                
                // Center the label in the view since we're center aligned text
                self.label.center = CGPoint(x: self.frame.midX, y: self.label.center.y)
                
                // After calling sizeToFit we need to reset our frames so they look correct
                self.label.frame = CGRect(x: self.label.frame.minX,
                                          y: self.label.frame.minY,
                                          width: self.label.frame.width,
                                          height: labelHeight)
                
                // ditto for subtitle
                self.subtitleLabel.center = CGPoint(x: self.frame.midX, y: self.subtitleLabel.center.y)
                self.subtitleLabel.frame = CGRect(x: self.subtitleLabel.frame.minX,
                                                  y: self.subtitleLabel.frame.minY,
                                                  width: self.subtitleLabel.frame.width,
                                                  height: subtitleLabelHeight)
                
                // Get the smallest X value so our image/activity indicator doesn't cover any thing
                let smallestXView = min(self.label.frame.minX, self.subtitleLabel.frame.minX)
                
                // If both our labels have 0 width (empty text) don't change the centers of our
                // image or activity indicator and just move along
                if self.label.frame.width == 0 && self.subtitleLabel.frame.width == 0 { return }
                
                // Move our image if that is what we're showing
                if (showingImage && toast.imageAlignment == .center) {
                    self.imageView.frame = CGRect(origin: CGPoint(x: smallestXView - self.imageView.frame.width - preferredPadding,
                                                                  y: self.imageView.frame.origin.y),
                                                  size: self.imageView.frame.size)
                }
                // Move our activity indicator over.
                if toast.showActivityIndicator && toast.activityIndicatorAlignment == .center {
                    self.activityIndicator.frame = CGRect(origin: CGPoint(x: smallestXView - self.activityIndicator.frame.width - preferredPadding,
                                                                          y: self.activityIndicator.frame.origin.y),
                                                          size: self.activityIndicator.frame.size)
                }
            }
        } else {
            print("Toast view with no toast?")
        }
    }

//    override public var frame: CGRect {
//        get {
//            print("<- frame : \(super.frame)")
//            return super.frame
//        }
//        set {
//            print("-> frame : \(newValue)")
//            super.frame = newValue
//        }
//    }
}
