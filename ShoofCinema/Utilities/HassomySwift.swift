//
//  HassomySwift3.swift
// 
//
//  Created by Husam Aamer on 15/12/16.
//  Copyright © 2016 AppChef. All rights reserved.
//

import UIKit

extension UIDevice {

    
    var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}

public func secoundBetween(start: Date, end: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: start, to: end).second!
}

func inset(view: UIView, insets: UIEdgeInsets) {
  if let superview = view.superview {
    view.translatesAutoresizingMaskIntoConstraints = false

    view.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: insets.left).isActive = true
    view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -insets.right).isActive = true
    view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
    view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
  }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
func in_main (_ block:@escaping () -> ()){
    DispatchQueue.main.async { () -> Void in
        block()
    }
}

func in_back (block:@escaping () -> ()){
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
        // do some task
        block()
    }
}
//In_back with high priority
func in_back_userInitiated (block:@escaping () -> ()) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
        // do some task
        block()
    }
}
var isApplicationActive:Bool {
    get {return UIApplication.shared.applicationState == .active}
}
func p(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        Swift.print(items[0], separator:separator, terminator: terminator)
    #endif
}

var screenWidth:CGFloat {
    get {
        return UIScreen.main.bounds.width
    }
}
var screenHeight:CGFloat {
    get {
        return UIScreen.main.bounds.height
    }
}
var appBuild : String {
    get {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
}
extension UIView {
    var parentTableView: UITableView? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let tv = parentResponder as? UITableView {
                return tv
            }
        }
        return nil
    }
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let vc = parentResponder as? UIViewController {
                return vc
            }
        }
        return nil
    }
}

extension String {
    var formattedDate:String {
        get {
            let format = DateFormatter()
            format.dateStyle = .medium
            format.dateFormat = "yyyy-MM-dd HH:mm:ss" //2016-12-15 18:10:58
            //format.timeZone = TimeZone(abbreviation: "UTC")
            
            if let date = format.date(from: self) {
                let formater = DateFormatter()
                formater.dateStyle = .short
                formater.timeStyle = .short
                formater.locale = Locale.init(identifier: "ar")
                return formater.string(from: date)
            }
            return ""
        }
    }
    
    var dateFromTimestamp : Date? {
        get {
            let format = DateFormatter()
            format.dateStyle  = .medium
            format.dateFormat = "yyyy-MM-dd HH:mm:ss" //2016-12-15 18:10:58
            format.timeZone = TimeZone(abbreviation: "UTC") // Server timezone
            
            if let date = format.date(from: self) {
                return date
            }
            return nil
        }
    }
    
}
extension Date {
    
    var currentUTCTimeZoneDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter.string(from: self)
    }
}
func delay(delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
    
}
func alert(title:String?, body:String?, cancel:String,actions:[UIAlertAction]? = nil, style:UIAlertController.Style = .alert) -> UIAlertController {
    let a = UIAlertController(title: title, message: body, preferredStyle: style)
    a.modalPresentationStyle = .fullScreen
    if let actionsArray = actions {
        for case let action in actionsArray as [UIAlertAction] {
            a.addAction(action)
        }
    }
    let cancel = UIAlertAction(title: cancel, style: .cancel,
                               handler: nil)
    a.addAction(cancel)
    return a
}
/*
 MARK: CGRect Extension
 */
extension CGRect {
    mutating func offsetY (_ y:CGFloat) {
        self = CGRect(x: origin.x, y: origin.y + y , width: self.width, height: self.height)
    }
    mutating func offsetX (_ x:CGFloat) {
        self = CGRect(x: origin.x + x, y: origin.y , width: self.width, height: self.height)
    }
    mutating func setX (_ x:CGFloat){
        self = CGRect(x: x, y: origin.y , width: self.width, height: self.height)
    }
    mutating func setY (_ y:CGFloat){
        self = CGRect(x: origin.x, y: y , width: self.width, height: self.height)
    }
    mutating func setH (_ H:CGFloat){
        self = CGRect(x: origin.x, y: origin.y , width: self.width, height: H)
    }
    mutating func setW (_ W:CGFloat){
        self = CGRect(x: origin.x, y: origin.y , width: W, height: self.height)
    }
    var center : CGPoint {
        return CGPoint(x: midX, y:midY)
    }
}
extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        let y = contentSize.height - frame.size.height
        let x = contentSize.width - frame.size.width
        setContentOffset(CGPoint(x: (x<0 ? 0 : x), y: (y<0) ? 0 : y), animated: animated)
    }
}
func Localize(_ key:String) -> String {
    return NSLocalizedString(key, comment: "")
}

struct Device {
    // iDevice detection code
    static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA           = UIScreen.main.scale >= 2.0
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH   = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6         = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P        = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X         = IS_IPHONE && SCREEN_MAX_LENGTH == 812
    static let IS_NOTCH_IPHONE     = IS_IPHONE && !IS_IPHONE_4_OR_LESS && !IS_IPHONE_5 && !IS_IPHONE_6 && !IS_IPHONE_6P
    
    static var HAS_NOTCH : Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
    }
}
var isArabic : Bool {
    get {
        if let languageCode = Locale.current.languageCode {
            switch languageCode {
            case "ar":
                return true
            default:
                return false
            }
        }
        return false
    }
}

func openFacebook (pageID:String, name:String) {
    let appURL = URL(string:"fb://profile/\(pageID)")!
    if UIApplication.shared.canOpenURL(appURL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    } else {
        let webURL = URL(string:"http://fb.me/\(name)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
    
}
func openAppStore(appID:String) {
    let storeURL = URL(string:"http://itunes.apple.com/app/id\(appID)")!
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(storeURL)
    }
}
func openFacebookMessenger (pageID:String, name:String) {
    let appURL = URL(string:"fb-messenger://user-thread/\(pageID)")!
    if UIApplication.shared.canOpenURL(appURL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    } else {
        let webURL = URL(string:"http://fb.me/\(name)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
    
}
func openYoutube (id:String) {
    guard let appURL = URL(string:"youtube://\(id)") else {
        let a = alert(title: "عذراً", body: "لا يمكن عرض الرابط \(id)", cancel: "حسناً")
        UIApplication.shared.keyWindow?.rootViewController?.present(a, animated: true, completion: nil)
        return
    }
    if UIApplication.shared.canOpenURL(appURL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    } else {
        let webURL = URL(string:"http://www.youtube.com/watch?v=\(id)")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
}

extension Float {
    var clean : String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self))!
    }
}
var screenSafeInsets: UIEdgeInsets {
    get {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        } else {
            return .zero
        }
    }
}
extension Int {
    var f : CGFloat {
        return CGFloat(self)
    }
}
extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
var isRTL:Bool {
    get {
        return UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft
    }
}
func loadingAlert (title:String) -> UIViewController {
    let alert = UIAlertController(title: nil, message: title, preferredStyle: .alert)
    
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.gray
    loadingIndicator.startAnimating();
    
    alert.view.addSubview(loadingIndicator)
    return alert
}

protocol ReuseIdentifying {
    static var identifier: String { get }
}
extension ReuseIdentifying {
    static var identifier: String {
        return String(describing: Self.self)
    }
}

extension UICollectionReusableView:ReuseIdentifying {}
extension UITableViewCell: ReuseIdentifying {}

