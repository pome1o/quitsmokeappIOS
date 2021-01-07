//
//  EmailVerfy.swift
//  testphp
//
//  Created by OITMIR on 2018/7/1.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CheckVerify {
    private var hostAccount = ""
    private var mysql : MySQLite? = nil
    private var view : UIViewController? = nil
    private var connect : ConnectPhp? = nil
    
    init(view : UIViewController) {
        self.hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        mysql = MySQLite.sharedInstance
        connect = ConnectPhp()
        self.view = view
    }
    
    //檢查是否驗證過
    func check() -> Bool {
        if let tempStatus = mysql?.get_app_data(key: KeyName().SQL_ACCOUNT_STATUS){
            if  tempStatus == "1" {
                return false
            }
        }
        return true
    }
    
    //跳出驗證信提示
    func showAlert() {
        let mail = mysql?.get_app_data(key: KeyName().SQL_USER_EMAIL)
        
        if mail != "" {
            let alertControll = UIAlertController(title: "請先驗證信箱", message: "請前往以下信箱：\n \(mail!)", preferredStyle: .alert)
            
            let reSend = UIAlertAction(title: "重新寄送", style: .default) { (action) in
                self.sendVerify(userMail: mail!, rebool: "1", mod: "sendverify", show: true)
            }
            
            let changeMail = UIAlertAction(title: "更換信箱", style: .default) { (action) in
                
                self.changeMailAlert()
                alertControll.dismiss(animated: false, completion: nil)
            }
            
            let ok = UIAlertAction(title: "知道", style: .cancel,handler: nil)
            
            alertControll.addAction(reSend)
            alertControll.addAction(changeMail)
            alertControll.addAction(ok)
            self.view?.present(alertControll, animated: true, completion: nil)
        }
    }
    
    //檢查是否為信箱格式
    func isValidEmail(mail : String) -> Bool {
        
        let testStr = mail
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        if result == false{
            return false
        }
        return true
    }
    
    //更換信箱輸入框
    func changeMailAlert(){
        
        let changeAlert = UIAlertController(title: "更換信箱", message: "請輸入新的信箱", preferredStyle: .alert)
        changeAlert.addTextField { (textField) in
            
        }
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            let newMailField = changeAlert.textFields?.first
            if (newMailField?.text?.count)! > 0 && self.isValidEmail(mail: (newMailField?.text!)!){
                self.sendVerify(userMail: (newMailField?.text!)!, rebool: "0", mod: "newemail", show: true)
                
                //關掉目前alert
                changeAlert.dismiss(animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel,handler: nil)
        
        changeAlert.addAction(okAction)
        changeAlert.addAction(cancelAction)
        
        self.view?.present(changeAlert, animated: true, completion: nil)
    }
    
    //發送
    func sendVerify(userMail :String,rebool : String,mod : String, show : Bool){
        
        if Connectivity.isConnected(){
            
            connect?.sendVerfiy(mail: userMail, account: hostAccount, rebool: rebool, mod: mod)
            connect?.doConnectString(success: {(value) -> Void in
                if (show){
                    if value == "200" {
                        var message = ""
                        if mod == "newemail" {
                            message = "更換信箱成功,請前往信箱收信"
                            self.mysql?.add_app_data(title:KeyName().SQL_USER_EMAIL, value: userMail)
                        }
                        
                        if mod == "sendverify" {
                            message = "以重新發送驗證"
                        }
                        
                        let responseAlert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
                        responseAlert.addAction(okAction)
                        self.view?.present(responseAlert, animated: true, completion: nil)
                    }
                }
            }, failure: {(error) -> Void in
                
            })
        }
    }
    
}
