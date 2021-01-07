//
//  MainViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/5/17.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON


class MainViewController: UITabBarController {
    var mydb : MySQLite? = nil
    var isFirst = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mydb = MySQLite.sharedInstance
        mydb?.iniDB()
        sendToken()
        _ = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        //print("mydebug:\(uri?.path)")
        // Do ay additional setup after loading the view.
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirst {
            isFirst = false
            let emailCheck = CheckVerify(view: self)
            if emailCheck.check() {
                emailCheck.showAlert()
            }
        }
        syncData()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    func syncData(){
        DispatchQueue.global().async {
            let sync = SyncData()
            sync.checkSync()
        }
    }
    
    func sendToken(){
        if Connectivity.isConnected() {
            if let token = UserDefaults.standard.string(forKey: KeyName().SHARE_FCM_TOKEN) {
                let connect = ConnectPhp()
                connect.sendToken(account: UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!, token: token)
                connect.doConnect(success: { (json) in
                    
                }) { (error) in
                    
                }
            }
        }
    }
    

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
