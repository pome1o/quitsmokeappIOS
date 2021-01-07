//
//  AppDelegate.swift
//  testphp
//
//  Created by OITMIB on 2018/3/21.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import SwiftyJSON



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var hostAccount = ""
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //判斷是否已經登入起始畫面
        var userDefault = UserDefaults.standard
        var viewController : UIViewController
        let uistoryboard = UIStoryboard(name: "Main",bundle: nil)
        if(userDefault.bool(forKey: KeyName().SHARE_LOGIN_COUNT)){
            viewController = uistoryboard.instantiateViewController(withIdentifier: "MainViewController")
        }else{
            viewController = uistoryboard.instantiateViewController(withIdentifier: "LoginView")
        }
        if let window = self.window{
            window.rootViewController = viewController
        }
        if let value = userDefault.string(forKey: KeyName().SHARE_ACCOUNT){
            hostAccount = value
        }
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
            Messaging.messaging().delegate = self
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { grand, error in
                if grand {
                    print("允許")
                }else{
                    print("不允許")
                }
            })
        }else{
            let setting : UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert], categories: nil)
            application.registerUserNotificationSettings(setting)
        }
        application.registerForRemoteNotifications()
        
        return true
    }
    
    //iOS 10 以下 接收
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        var mysql = MySQLite.sharedInstance
        var aps = JSON(userInfo["aps"]!)
        print("接收10以下background: is in ? \(aps["content-available"].intValue)")
        if aps != JSON.null && aps["content-available"].intValue == 1 {
            if let friendRequest =  userInfo["new_supporter"] {
                //好友申請
                mysql?.add_app_data(title: KeyName().SQL_FRIEND_REQUEST, value: "1")
            }else if let isReply = userInfo["isreply"] {
                //訊息
                
                var id = userInfo["id"] as! String
                print("接收10以下background: is in ?")
                var reply_id = "0"
                if  Bool(userInfo["isreply"]! as! String ) == true {
                    
                    reply_id = (userInfo["reply_id"] as! String)
                }
                print("appdele isReply? :")
                
                var messageType = userInfo["type"] as! String
                var path = ""
                var title = userInfo["title"] as! String
                var message = userInfo["body"] as! String
                var fromWho = userInfo["fromwho"] as! String
                var time = userInfo["date"] as! String
                
                
                if let fileUrl = userInfo["url"] {
                    print("lee :123")
                    path = (fileUrl as! String)
                    path = downloadFile(url: path, fromWho: fromWho)
                    var downloadOk = 0
                    if path != "" {
                        downloadOk = 1
                    }else{
                        path = (fileUrl as! String)
                        downloadOk = 0
                    }
                    mysql?.add_message(id: String(id), reply_id: reply_id, msg: message, type: messageType, path: path, title: title, frome_who: fromWho, to_who: hostAccount, timestamp: time, isdownload: downloadOk)
                }else{
                    mysql?.add_message(id: String(id), reply_id: reply_id, msg: message, type: messageType, path: path, title: title, frome_who: fromWho, to_who: hostAccount, timestamp: time, isdownload: 1)
                }
            }else if let sync = userInfo["sync"]{
                //同步資料
                mysql?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
            }
        }
    }
    
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         print("接收10以下background: is in ? \(userInfo)")
        var mysql = MySQLite.sharedInstance
        var aps = JSON(userInfo["aps"]!)
        print("接收10以下background: is in ? \(aps["content-available"].intValue)")
        if aps != JSON.null && aps["content-available"].intValue == 1 {
            if let friendRequest =  userInfo["new_supporter"] {
                //好友申請
                mysql?.add_app_data(title: KeyName().SQL_FRIEND_REQUEST, value: "1")
            }else if let isReply = userInfo["isreply"] {
                //訊息
                
                var id = userInfo["id"] as! String
                print("接收10以下background: is in ?")
                var reply_id = "0"
                if  Bool(userInfo["isreply"]! as! String ) == true {
                    
                    reply_id = (userInfo["reply_id"] as! String)
                }
                print("appdele isReply? :")
                
                var messageType = userInfo["type"] as! String
                var path = ""
                var title = userInfo["title"] as! String
                var message = userInfo["body"] as! String
                var fromWho = userInfo["fromwho"] as! String
                var time = userInfo["date"] as! String
                
                
                if let fileUrl = userInfo["url"] {
                    print("lee :123")
                    path = (fileUrl as! String)
                    path = downloadFile(url: path, fromWho: fromWho)
                    var downloadOk = 0
                    if path != "" {
                        downloadOk = 1
                    }else{
                        path = (fileUrl as! String)
                        downloadOk = 0
                    }
                    mysql?.add_message(id: String(id), reply_id: reply_id, msg: message, type: messageType, path: path, title: title, frome_who: fromWho, to_who: hostAccount, timestamp: time, isdownload: downloadOk)
                }else{
                    mysql?.add_message(id: String(id), reply_id: reply_id, msg: message, type: messageType, path: path, title: title, frome_who: fromWho, to_who: hostAccount, timestamp: time, isdownload: 1)
                }
            }else if let sync = userInfo["sync"]{
                //同步資料
                mysql?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //推播註冊成功
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02", $1)})
        //print("device token : \(token)")
    }
    
    //推播註冊失敗
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("mydebug registerFail: \(error)")
    }
    
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func downloadFile(url : String, fromWho : String) -> String{
        let group = DispatchGroup()
        
        var tempSplit = url.components(separatedBy: "uploads/")
        let uri = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let dirPath = uri?.appendingPathComponent(fromWho).path
        var fileName = tempSplit[1]
        checkDirEx(path: dirPath!)
        let realPath = dirPath! + "/\(fileName)"
        if(!FileManager.default.fileExists(atPath: realPath)){
            
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
        }
        return fileName
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

@available(iOS 10,*)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        var mysql = MySQLite.sharedInstance
        var aps = JSON(userInfo["aps"]!)
        print("接收10以下background: is in ? \(aps["content-available"].intValue)")
        if aps != JSON.null && aps["content-available"].intValue == 1 {
            if let friendRequest =  userInfo["new_supporter"] {
                //好友申請
                mysql?.add_app_data(title: KeyName().SQL_FRIEND_REQUEST, value: "1")
            }else if let isReply = userInfo["isreply"] {
                //訊息
                
                var id = userInfo["id"] as! String
                print("接收10以下background: is in ?")
                var reply_id = "0"
                if  Bool(userInfo["isreply"]! as! String ) == true {
                    
                    reply_id = (userInfo["reply_id"] as! String)
                }
                print("appdele isReply? :")
                
                var messageType = userInfo["type"] as! String
                var path = ""
                var title = userInfo["title"] as! String
                var message = userInfo["body"] as! String
                var fromWho = userInfo["fromwho"] as! String
                var time = userInfo["date"] as! String
                
                
                if let fileUrl = userInfo["url"] {
                    print("lee :123")
                    path = (fileUrl as! String)
                    path = downloadFile(url: path, fromWho: fromWho)
                    var downloadOk = 0
                    if path != "" {
                        downloadOk = 1
                    }else{
                        path = (fileUrl as! String)
                        downloadOk = 0
                    }
                    mysql?.add_message(id: String(id), reply_id: reply_id, msg: message, type: messageType, path: path, title: title, frome_who: fromWho, to_who: hostAccount, timestamp: time, isdownload: downloadOk)
                }else{
                    mysql?.add_message(id: String(id), reply_id: reply_id, msg: message, type: messageType, path: path, title: title, frome_who: fromWho, to_who: hostAccount, timestamp: time, isdownload: 1)
                }
            }else if let sync = userInfo["sync"]{
                //同步資料
                mysql?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
            }
        }
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //點擊
        let info = response.notification.request.content.userInfo
        print("iOS 10 以上: \(info)")
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("mydebug remoteData:\(remoteMessage.appData)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("firebase token: \(fcmToken)")
        if fcmToken != nil {
            UserDefaults.standard.set(fcmToken, forKey: KeyName().SHARE_FCM_TOKEN)
        }
    }
}


