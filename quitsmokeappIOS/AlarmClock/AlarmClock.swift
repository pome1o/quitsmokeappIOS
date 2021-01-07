//
//  AlarmClock.swift
//  testphp
//
//  Created by OITMIR on 2018/6/29.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import UserNotifications


class AlarmClock {
    
    private var randomMessage : [MessageStruct] = []
    private var mysql : MySQLite? = nil
    private var fromTime = 0
    private var toTime = 0
    
    init() {
        mysql = MySQLite.sharedInstance
    }
    
    func setFrom(from : Int){
        fromTime = from
    }
    
    func setTo(to : Int){
        toTime = to
    }
    
    private func getMessage(){
        randomMessage = (mysql?.get_random_message(hostAccount: UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!))!
        
    }
    
    func setUpNotification(){
        let notifyCenter = UNUserNotificationCenter.current()
        let timeCount = (toTime - fromTime) + 1
        self.getMessage()
        let messageCount = randomMessage.count
        //如果總時間大於現有資料庫訊息 就會使用內建訊息
        if messageCount < timeCount {
            let messageInterval = timeCount - messageCount
            for _ in 0...messageInterval {
                randomMessage.append(MessageStruct(_id: 0, reply: 0, msg_type: "text", file_name: "", message: "請不要抽菸", from: "", to: "", title: "系統", datetime: "", is_download: 0))
            }
        }
        
        var posistion = 0
        
        //用迴圈新增NOTIFICATION 排程
        for i in fromTime...toTime {
            let calendar = Calendar.current.date(bySettingHour: i, minute: 0, second: 0, of: Date())
            let component = Calendar.current.dateComponents([.hour,.minute,.second], from: calendar!)
            let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
            
            let content = UNMutableNotificationContent()
            
            content.title = "定時提醒\(randomMessage[posistion].title!)"
            
            if randomMessage[posistion].msg_type == "text" {
                content.body = randomMessage[posistion].message!
            }else{
                do{
                    
                let uri = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                var dirPath = uri?.appendingPathComponent(randomMessage[posistion].from!)
                 dirPath = dirPath?.appendingPathComponent(randomMessage[posistion].file_name!)
                let attachment = try UNNotificationAttachment(identifier: "haveFile", url: dirPath!, options: nil)
                content.attachments = [attachment]
                }catch{
                    
                }
            }
            
            let request = UNNotificationRequest(identifier: "alarm\(i)", content: content, trigger: trigger)
            notifyCenter.add(request, withCompletionHandler: nil)
            posistion = posistion + 1
        }
    }
    
    
    func cancelAlarm(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    
    
}
