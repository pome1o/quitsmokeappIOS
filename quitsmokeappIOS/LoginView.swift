//
//  ViewController.swift
//  testphp
//
//  Created by OITMIB on 2018/3/21.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginView : UIViewController {

    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var textUserPassword: UITextField!
    @IBOutlet weak var textUserName: UITextField!
    var activityIndicator : UIActivityIndicatorView!
    var mydb : MySQLite? = nil
    var userDefault : UserDefaults? = nil
    var userPassword : String = ""
    var userAccount : String = ""
    var connet : ConnectPhp? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connet = ConnectPhp()
        
        userDefault = UserDefaults.standard
        //判斷是否第一次登入寫在 AppDelegate
        
        mydb = MySQLite.sharedInstance
        mydb?.iniDB()
        //判斷是否是第一次安裝程式
        if userDefault?.integer(forKey: KeyName().SHARE_INI) == 0 {
            initUserStore()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //傳值到另一頁
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginView"{
            let mainController = segue.destination as! MainViewController
            //mainController.dataFromPageOne = "this data from page one"
        }
    }
    
    //登入按鈕
    @IBAction func onclick(_ sender: UIButton) {
        login()
    }
    
    
    //登入
    func login(){
        let temp_name = textUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        var temp_password = textUserPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (temp_name!.count >= 6 && temp_password!.count >= 6) {
            print("click")
            let encrpypt = DataEncrypt()
            userPassword = encrpypt.encode(data: temp_password!)!
            userAccount = temp_name!
            connet?.login(user_name: userAccount, password:userPassword)
            
            connet?.doConnect(
                success: {(respon) -> Void in
                    print(respon)
                    var isAlert = false
                    if let status : String =  respon["log"].string {
                        var alertMessage = ""
                  
                        switch status {
                        case "correct" :
                            self.processLoginData(respon: respon)
                            
                            break
                        case "no_account" :
                            isAlert = true
                            alertMessage = "無此帳號"
                            break
                        case "wrongpw" :
                            isAlert = true
                            alertMessage = "密碼錯誤"
                            break
                        default:
                            isAlert = true
                            
                            break
                        }
                        if isAlert {
                            let alertAction = UIAlertAction(title: "確定", style: .default,
                                                            handler:{(action: UIAlertAction) -> Void in
                                                                
                            })
                            let alertControll = UIAlertController(title: "提示", message: alertMessage, preferredStyle: .alert)
                            alertControll.addAction(alertAction)
                            
                            self.present(alertControll, animated: true, completion: nil)
                        }
                    }
                    
            },
                failure: {(error)-> Void in
                    print("\(error)")
            })
        }else{
            let alertAction = UIAlertAction(title: "確定", style: .default,
                                            handler:nil)
            let alertControll = UIAlertController(title: "提示", message: "帳號小或密碼小於6", preferredStyle: .alert)
            alertControll.addAction(alertAction)
            
            self.present(alertControll, animated: true, completion: nil)
        }
    }
    
    func processLoginData(respon : JSON){
      
        userDefault?.set(userPassword,forKey: KeyName().SHARE_PASSWORD)
        userDefault?.set(userAccount,forKey: KeyName().SHARE_ACCOUNT)
        userDefault?.set(0,forKey: KeyName().SHARE_FCM_RE)
        userDefault?.set(true, forKey: KeyName().SHARE_LOGIN_COUNT)
        if(userDefault?.integer(forKey : KeyName().SHARE_LOGING_OLD) == 0) {
            do{
                for(key,subjson):(String,JSON) in respon["data"] {
                    if var value = subjson.string{
                        if(value.count <= 0){
                            value = ""
                        }
                        mydb?.add_app_data(title: key, value: value)
                    }
                }
            }
        }
        mydb?.add_app_data(title: KeyName().SQL_USER_ACCOUNT, value: userAccount)
        mydb?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
        userDefault?.set(1, forKey: KeyName().SHARE_LOGING_OLD)
        userDefault?.set(true, forKey: KeyName().SHARE_LOGIN_COUNT)
        syncSmoke()
         self.performSegue(withIdentifier: "loginToMain", sender: nil)
    }
    
    //新建資料庫資料
    func initUserStore(){
        
        mydb?.add_app_data(title: KeyName().SQL_SYNC_FRIEND, value: "1")
        mydb?.add_app_data(title: KeyName().SQL_SYNC_USER, value: "1")
        mydb?.add_app_data(title: KeyName().SQL_SYNC_SMOKE_TIME, value: "0")
        mydb?.add_app_data(title: KeyName().SQL_SYNC_SMOKE, value: "0")
        userDefault?.set(1, forKey: KeyName().SHARE_INI)
    }
    
    func syncSmoke(){
        DispatchQueue.global().async {
            let sync = SyncToDevice()
            sync.syncSmoke()
        }
        
    }

}

