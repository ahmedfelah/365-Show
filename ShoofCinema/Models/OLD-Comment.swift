import SwiftyJSON

struct Comment:Codable {
    var message:String
    var id:Int
    var username:String
    var user_id:Int
    var date:String
    
    init? (from json:JSON){
        
        guard
            let _message    = json["comment_txt"].string,
            let _date       = json["comment_date"].string,
            let _id         = json["comment_id"].int,
            let _username   = json["user"]["user_name"].string,
            let _user_id    = json["user"]["user_id"].int
            else {
                return nil
        }
        
        message     = _message
        id          = _id
        username    = _username
        user_id     = _user_id
        date        = _date
    }
    init (id:Int,message:String, username:String, user_id:Int, date:String) {
        self.id = id
        self.message = message
        self.username = username
        self.user_id = user_id
        self.date = date
    }
}
