//
//  NotificationService.swift
//  notifyService
//
//  Created by OITMIR on 2018/6/27.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
         print("notification service out")
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title)"
            
            let userInfo = bestAttemptContent.userInfo
            var url = ""
            if let tempType = userInfo["type"] {
                if (tempType as! String) != "text" {
                    url = userInfo["url"] as! String
                    url = downloadFile(url: url, fromWho: userInfo["fromwho"] as! String)
                    do{
                        let attach = try UNNotificationAttachment(identifier: "image", url: URL(fileURLWithPath: url), options: nil)
                        bestAttemptContent.attachments = [attach]
                    }catch{
                        debugPrint(error)
                    }
                }
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
         print("notification service time will")
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func downloadFile(url : String, fromWho : String) -> String{
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
        print(realPath)
        return realPath
    }
    
    func checkDirEx(path : String){
        var isDir : ObjCBool = false
        if !(FileManager.default.fileExists(atPath: path, isDirectory: &isDir)) && !isDir.boolValue{
            do{
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch let error as Error {
                print(error.localizedDescription)
            }
        }
    }

}

