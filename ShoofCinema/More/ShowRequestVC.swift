//
//  ShowRequestTVC.swift
//  SuperCell
//
//  Created by Husam Aamer on 6/17/19.
//  Copyright © 2019 AppChief. All rights reserved.
//

import UIKit
import SwiftyJSON

class ShowRequestVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var data:JSON!
    var fieldView:MessageFieldView!
    @IBOutlet weak var tableView:UITableView!
    
    lazy var df = DateFormatter()
    lazy var dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = Colors.background
        
        title = data["user"]["user_name"].stringValue
        
        fieldView = .init(frame: .zero)
        view.addSubview(fieldView)
        
        fieldView.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                $0.bottom.equalToSuperview()
            }
        })
        
        
        df.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        
    }

    // MARK: - Table view data source


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data["reply"].arrayValue.count + 1
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var item : JSON = {
            return indexPath.row == 0 ? data : data["reply"][indexPath.row-1]
        }()
        var textColor = UIColor.white
        let id : String = {
            if indexPath.row == 0 {
                return "rightCell"
            }
            if data["user"]["user_id"].stringValue == item["user"]["user_id"].stringValue {
                return "rightCell"
            }
            textColor = .black
            return "leftCell"
        }()
        let c = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! MessageTableViewCell
        
        var msg_date : String = ""
        if indexPath.row == 0 {
            print(item["reply_txt"].stringValue)
            c.bodyLabel.attributedText = item["request_txt"].stringValue.html2Attributed(with: textColor)
            msg_date = item["request_time"].stringValue
        } else {
            c.bodyLabel.attributedText = item["reply_txt"].stringValue.html2Attributed(with: textColor)
            msg_date = item["reply_time"].stringValue
        }
        
        //Set pretty date
        if let date = df.date(from: msg_date) {
            let pretty = dateFormatter.string(from: date)
            c.dateLabel.text = pretty
        } else {
            c.dateLabel.text = nil
        }
        
        //Set user name
        c.username?.text = item["user"]["user_name"].stringValue
        
        return c
    }
    
    func htmlToAttributedString (_ string:String) -> NSAttributedString? {
        let data = Data(string.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [
            .documentType: NSAttributedString.DocumentType.html
            ], documentAttributes: nil) {
            return  attributedString
        }
        return nil
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension String {
    func html2Attributed(with color:UIColor) -> NSAttributedString? {
        guard let attr = html2Attributed else {
            return nil
        }
        
        //Change writing direction
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.baseWritingDirection = .rightToLeft
        
        attr.addAttributes([
            NSAttributedString.Key.foregroundColor : color,
            NSAttributedString.Key.font : Fonts.hacen_lite(17),
            NSAttributedString.Key.paragraphStyle : paragraphStyle
            ], range: NSRange(location: 0, length: attr.length))
        
        return attr
    }
    var html2Attributed: NSMutableAttributedString? {
        do {
            let str = self//"<!DOCTYPE html><html><body>\(self)</body></html>"
            guard let data = str.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSMutableAttributedString(
                data: data,
                options:[
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
}

