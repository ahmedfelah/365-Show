
import UIKit

class CurvedTabbar: UITabBar {
    var radii: CGFloat = 20

    private var shapeLayer: CALayer?
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        
        appearance()
    }

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addShape()
    }
    
    private func appearance () {
        UITabBar.appearance().tintColor = Theme.current.tintColor
        UITabBar.appearance().barTintColor = .clear
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        itemPositioning = .centered
        
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.fillColor = Theme.current.tabbarColor.cgColor
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radii, height: 0.0))

        return path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        var tabFrame            = self.frame
        if #available(iOS 11.0, *) {
            tabFrame.size.height  = 55 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? CGFloat.zero)
            tabFrame.origin.y = self.frame.origin.y +   ( self.frame.height - 55 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? CGFloat.zero))
        } else {
            tabFrame.size.height  = 65
            tabFrame.origin.y  = self.frame.origin.y
        }
        self.layer.cornerRadius = 20
        self.frame = tabFrame
        self.items?.forEach({
            // Hide titles
            $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0)
            
            // Center image vertically
            $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        })
        
    }

    override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        
        /**
         
         **BUG FIX**
         Don't make an item for under player child view controller
         
         */
        if let tabController = parentViewController as? RoundedTabBar {
            if items?.last == tabController.detailsChild?.tabBarItem {
                super.setItems(items?.filter({$0 != items?.last}), animated: animated)
                return
            }
        }
        
        super.setItems(items, animated: animated)
    }
}
