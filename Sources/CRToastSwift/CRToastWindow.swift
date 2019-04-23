import Foundation

import UIKit

public class CRToastWindow : UIWindow {
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if subview.hitTest(self.convert(point, to: subview), with: event) != nil { return true }
        }
        return false
    }
}
