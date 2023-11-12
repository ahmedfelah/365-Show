//
//  AboutVC.swift
//  Shoof
//
//  Created by Husam Aamer on 11/3/17.
//  Copyright © 2017 HA. All rights reserved.
//

import UIKit
import MessageUI
import Kingfisher

struct AboutACButton:Codable {
    var img_link:URL
    var link_ios:String
    //var link_and:String?
    var target  :String
    var tint    :[Int]?
    
    var tintColor : UIColor? {
        if let tint = tint {
            if tint.count == 3 {
                return UIColor(red: tint[0].f/255, green: tint[1].f/255, blue: tint[2].f/255, alpha: 1)
            }
        }
        return nil
    }
}
struct AboutACStruct : Codable {
    var logo:URL
    var logo_dark:URL?
    var slog:String?
    var comment:String?
    var website:URL?
    var credits:[String]?
    var social_networks:[AboutACButton]?
}
class AboutVC: MasterTVC , MFMailComposeViewControllerDelegate {

    var info:AboutACStruct!

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var slog: UILabel!
    

    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var user_id: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = NSLocalizedString("version", comment: "")  + " :" + "\(versionString)"
        }
        
        title = nil
        
        view.backgroundColor = Theme.current.backgroundColor
        
        logoView.kf.setImage(with: info.logo_dark)
        slog.text    = info.slog
        credits.text = info.credits?.joined(separator: "\n")
        comment.text = info.comment
        
//        if let buttons = info.social_networks {
//            for (i,b) in buttons.enumerated() {
//                
//                KingfisherManager.shared
//                    .retrieveImage(with: b.img_link,
//                 options: nil,
//                 progressBlock: nil,
//                 completionHandler: { (img, err, _, _) in
//                    if let img = img {
//                        let but = UIButton(type: .custom)
//                        but.heightAnchor.constraint(lessThanOrEqualToConstant: 45).isActive = true
//                        but.tag = i
//                        if let tint = b.tintColor {
//                            let renderImage = img.withRenderingMode(.alwaysTemplate)
//                            but.tintColor = tint
//                            but.setImage(renderImage, for: .normal)
//                        } else {
//                            but.setImage(img, for: .normal)
//                        }
//                        but.addTarget(self,
//                                      action: #selector(self.buttonAction(_:)),
//                                      for: .touchUpInside)
//                        but.imageView?.contentMode = .scaleAspectFit
//                        self.buttonsStack.addArrangedSubview(but)
//                    }
//                })
//            }
//        }
    }
    
    @IBAction func logoTapped(_ sender: Any) {
        if let url = URL(string:"https://www.appchief.net/home") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonAction (_ sender:UIButton) {
        let index = sender.tag
        let buttonInfo = info.social_networks![index]
        
        switch buttonInfo.target {
        case "fb":
            openFacebook(pageID: buttonInfo.link_ios, name: buttonInfo.link_ios)
            break
        case "link":
            guard let link = URL(string: buttonInfo.link_ios) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(link)
            }
            break
        case "email":
            send(email: buttonInfo.link_ios)
            break
        default:
            return
        }
        
    }
    func send (email:String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("*يرجى ملاحظة أن مطور التطبيق غير مسؤول عن توقف الخدمة أو حالة او نوع المحتوى والمشاكل التي قد تحدث بسبب الخادم (السيرفر).. اذا صادفتك احدى هذه المشاكل يرجى التواصل مع الشركة المزوده للخدمة", isHTML: true)
            present(mail, animated: true)
        } else {
            tabBar?.alert.genericError()
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }


}
