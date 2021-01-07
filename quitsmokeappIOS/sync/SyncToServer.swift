//
//  SyncToServer.swift
//  testphp
//
//  Created by OITMIR on 2018/6/18.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import SwiftyJSON

class SyncToServer {
    var mysql : MySQLite? = nil
    var connect : ConnectPhp? = nil
    var userDefault : UserDefaults? = nil
    init() {
        mysql = MySQLite.sharedInstance
        connect = ConnectPhp()
        userDefault = UserDefaults.standard
    }
    
    func changeSyncStatus(){
        connect?.changeSync(account: (userDefault?.string(forKey: KeyName().SHARE_ACCOUNT))!, status: (mysql?.get_app_data(key: KeyName().SQL_SYNC_FRIEND))!)
        connect?.doConnect(success: { (json) in
            
        }, failure: { (error) in
            
        })
        
    }
    
    func syncUserInfo(){
        if !(userDefault?.bool(forKey: KeyName().SHARE_LOGIN_COUNT))! {
            return
        }
        var dataKey : [String] = []
        var dataValue : [String] = []
        let keyName = KeyName().SQL_USER_INFO
        for value in keyName {
            dataKey.append(value)
            dataValue.append((mysql?.get_app_data(key: value))!)
            
        }
        let account = userDefault?.string(forKey: KeyName().SHARE_ACCOUNT)
        connect?.upDateUserInfo(account: account!, dataKey: dataKey, dataValue: dataValue)
        connect?.doConnect(success: {(respon) -> Void in
            
            if respon != JSON.null {
                
                self.mysql?.add_app_data(title: KeyName().SQL_SYNC_USER, value: "0");
            }else{
                self.mysql?.add_app_data(title: KeyName().SQL_SYNC_USER, value: "1");
            }
        }, failure: {(error) -> Void in
            self.mysql?.add_app_data(title: KeyName().SQL_SYNC_USER, value: "1");
        })
        
    }
    
    func syncSmokeCount() {
        let statment =  mysql?.fetchSmokeUpdate()
        var str1 = ""
        var str2 = ""
        var str3 = ""
        while sqlite3_step(statment) == SQLITE_ROW {
            str1 += "\(String(cString: sqlite3_column_text(statment, 1)))\r\n"
            str2 += "\(String(cString: sqlite3_column_text(statment, 2)))\r\n"
            str3 += "\(String(cString: sqlite3_column_text(statment, 3)))\r\n"
        }
         
        connect?.upload_smoke(account: str1, date: str2, time: str3)
        connect?.doConnect(success: {(respon) -> Void in
            self.mysql?.add_app_data(title: KeyName().SQL_SYNC_SMOKE, value: "0");
             print("mydebug\(respon)")
        }, failure: {(error) -> Void in
            self.mysql?.add_app_data(title: KeyName().SQL_SYNC_SMOKE, value: "1");
            print("mydebug\(error)")
        })
    }
    
    
    
}
