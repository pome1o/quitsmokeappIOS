//
//  SyncData.swift
//  testphp
//
//  Created by OITMIR on 2018/6/18.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import SwiftyJSON

class SyncData  {
    func checkSync(){
        let mydb = MySQLite.sharedInstance
        let connect = ConnectPhp()
        let syncKey : [String] = [KeyName().SQL_SYNC_FRIEND, KeyName().SQL_SYNC_USER, KeyName().SQL_SYNC_SMOKE]
        
        if Connectivity.isConnected(){
            let syncToDevice = SyncToDevice()
            let syncToServer = SyncToServer()
            if let account = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT){
                
                connect.checkSync(account: account)
                connect.doConnect(success: {(respon) -> Void in
                    if respon != JSON.null {
                        print(respon)
                        var job = respon["data"]
                        if job["_sync_new_friend"].string == "1"{
                            mydb?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
                        }else{
                            mydb?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "0")
                        }
                        mydb?.add_app_data(title: KeyName().SQL_ACCOUNT_STATUS, value: job["_account_status"].string!)
                    }
                }, failure: {(error) -> Void in
                    
                })
                
                //判斷哪些資料表需要同步
                for value in syncKey {
                    var checkValue = ""
                    
                    checkValue = (mydb?.get_app_data(key: value))!
                    
                    if checkValue != "" && checkValue == "1" {
                        
                        switch value {
                        case KeyName().SQL_SYNC_USER:
                            syncToServer.syncUserInfo()
                            break
                        case KeyName().SQL_SYNC_FRIEND:
                            syncToDevice.syncFriend()
                            break
                        case KeyName().SQL_SYNC_SMOKE:
                            print("mydebug\(checkValue)")
                            syncToServer.syncSmokeCount()
                            break
                        default:
                            break
                        }
                    }
                }
                syncToServer.changeSyncStatus()
                syncToDevice.syncMessage()
            }
        }
        
    }
}
