//
//  SyncToDevice.swift
//  testphp
//
//  Created by OITMIR on 2018/6/18.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class SyncToDevice {
    
    var mysql : MySQLite? = nil
    var connect : ConnectPhp? = nil
    var userDefault : UserDefaults? = nil
    init() {
        mysql = MySQLite.sharedInstance
        connect = ConnectPhp()
        userDefault = UserDefaults.standard
    }
    
    func syncFriend(){
        var allFirend = mysql?.get_all_friend_list()
        let account = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)
        connect?.syncFriend(account: account!)
        connect?.doConnect(success: {(respon) -> Void in
            print("synFriend : \(respon)")
            if respon != JSON.null{
                if respon["ck"] == "no friend"{
                    self.mysql?.del_all(tableName: (self.mysql?.TABLE_FRIEND)!)
                }else{
                    var jsonName = respon["name"]
                    let jsonAccount = respon["account"]
                    var jsonType = respon["user_type"]
                    var tempArray : [String] = []
                    
                    for(i,value) : (String,JSON) in jsonAccount {
                        tempArray.append(value.string!)
                        self.mysql?.add_friend(friend_id: value.string!, friend_name: jsonName[Int(i)!].string!, type: jsonType[Int(i)!].string!)
                    }
                    if (allFirend?.count)! > 0 {
                        for i in 0...(allFirend?.count)!-1 {
                            let friendAccount = allFirend![i].account!
                            if !(tempArray.contains(friendAccount)) {
                                self.mysql?.del_friend(friend_id: allFirend![i].account!)
                            }
                        }
                    }
                }
                self.mysql?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "0")
            }
        }, failure: {(error) -> Void in
            debugPrint(error)
            self.mysql?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
        })
    }
    
    func syncMessage(){
        var data = mysql?.lastTime(type: 0, account: "")
        var lastTime = "no"
        if (data?.count)! > 0 {
            lastTime = data![0].datetime!
        }
        print("\(lastTime)")
        let account = userDefault?.string(forKey: KeyName().SHARE_ACCOUNT)
        connect?.getMessageFromServer(account: account!, lastTime: lastTime)
        connect?.doConnect(success: {(respon) -> Void in
            print("syncMessage:\(respon)")
            let request = respon["request"].string
            if request == "have_data" {
                let jsonArray = respon["message"]
                
                for (_,jsonObj) : (String ,JSON) in jsonArray {
                    var data = MessageStruct(_id: Int(jsonObj["_id"].string!)!, reply: Int(jsonObj["_reply"].string!)!, msg_type: jsonObj["_type"].string, file_name: jsonObj["_path"].string, message: jsonObj["_message"].string, from: jsonObj["_from_who"].string, to: jsonObj["_to_who"].string, title: jsonObj["_name"].string, datetime: jsonObj["_time"].string, is_download: 0)
                    
                    if(data.msg_type != "text"){
                        var fileName = data.from
                        if data.from == account {
                            fileName = data.to
                        }
                        let temp_path = self.downloadFile(url: data.file_name!, fromWho: fileName!, type: data.msg_type!)
                        if temp_path != "" {
                            data.is_download = 1
                            data.file_name = temp_path
                        }
                        
                    }else{
                        data.is_download = 1
                    }
                    self.mysql?.add_message(id: String(data._id), reply_id: String(data.reply), msg: data.message!, type: data.msg_type!, path: data.file_name!, title: data.title!, frome_who: data.from!, to_who: data.to!, timestamp: data.datetime!, isdownload: data.is_download)
                   
                }
                 NotificationCenter.default.post(name: Notification.Name("updateMain"), object: nil)
            }
        }, failure:{ (error)-> Void in
            debugPrint(error)
        })
    }
    
    func syncSmoke(){
        let account = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)
        connect?.loadSmoke(account: account!)
        connect?.doConnect(success: { (json) in
            
             if json["friend_all_date"].count > 0 {
                self.mysql?.load_smoke_data(account: account!, date: json["friend_all_date"], time: json["friend_all_time"])
            }
        }, failure: { (error) in
            print("mydebug\(error)")
        })
    }
    
    func downloadFile(url : String, fromWho : String, type : String) -> String{
        let group = DispatchGroup()
        
       var tempSplit = url.components(separatedBy: "uploads/")
        let uri = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let dirPath = uri?.appendingPathComponent(fromWho).path
        var fileName = tempSplit[1]
        
        checkDirEx(path: dirPath!)
        let realPath = dirPath! + "/\(fileName)"
       
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {(data,respon,error) -> Void in
            if error == nil {
            FileManager.default.createFile(atPath: realPath, contents: data, attributes: nil)
                
            }else{
                fileName = ""
            }
            group.leave()
        })
        group.enter()
        task.resume()
        group.wait()
        
        return fileName
    }
    
    func checkDirEx(path : String){
        var isDir : ObjCBool = false
        if !(FileManager.default.fileExists(atPath: path, isDirectory: &isDir)) && !isDir.boolValue{
            do{
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch  {
                print(error.localizedDescription)
            }
        }
    }
    
}
