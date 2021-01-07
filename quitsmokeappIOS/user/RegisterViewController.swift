//
//  RegisterViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/23.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON

class RegisterViewController: UIViewController,UITextFieldDelegate {
    
    var userType = 2
    @IBOutlet weak var userAccount: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var passwordRe: UITextField!
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userNickName: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //when press return on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func radioButton(_ sender: UIButton) {
        
        for i in 0...1 {
            if sender.tag == i + 101 {
                sender.isSelected = true
                switch sender.tag {
                case 101:
                    userType = 0
                    break
                case 102:
                    userType = 2
                    break
                default:
                    userType = 2
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 101) as! UIButton
            Btn.isSelected = false
        }
    }
    
    
    
    
    
    func isValidEmail() -> Bool {
        if (userMail.text?.count)! <= 0{
            userMail.layer.borderColor = UIColor.red.cgColor
            return false
        }
        let testStr = userMail.text!
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        if result == false{
            userMail.layer.borderColor = UIColor.red.cgColor
            return false
        }
        return true
    }
    
    func checkAccount() -> Bool{
        if (userAccount.text?.count)! >= 6 {
            return true
        }
        userAccount.layer.borderColor = UIColor.red.cgColor
        return false
    }
    
    func checkPassword() -> Bool {
        if (userPassword.text?.count)! >= 6 && (passwordRe.text?.count)! >= 6 {
            if userPassword.text == passwordRe.text{
                return true
            }
        }
        passwordRe.layer.borderColor = UIColor.red.cgColor
        userPassword.layer.borderColor = UIColor.red.cgColor
        return false
    }
    
    func checkNick() -> Bool {
        if (userNickName.text?.count)! > 0 {
            return true
        }
        return false
    }
    
    var buttonCount = 0
    
    @IBAction func sendClick(_ sender: Any) {
        if buttonCount == 0 {
            send()
        }else{
            goNextPage()
        }
    }
    
    func goNextPage(){
        self.performSegue(withIdentifier: "registerToProfile", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerToProfile" {
            let profileVC = segue.destination as! ChangeProfileViewController
            profileVC.fromVC = "register"
        }
    }
    
    //發送
    func send(){
        
        let connect = ConnectPhp()
        if checkPassword() && checkNick() && checkPassword() && isValidEmail() {
            let encrpypt = DataEncrypt()
            let encodedPassword = encrpypt.encode(data: userPassword.text!)
            
            connect.registered_user(account: userAccount.text!, password: encodedPassword!, name: userNickName.text!, mail: userMail.text!, type: userType)
            connect.doConnect(success: {(respon) -> Void in
                var alertMessage = ""
                var doAlert = false
                if respon != JSON.null {
                    let status = respon["ck"]
                    switch status {
                    case "repeat":
                        doAlert = true
                        alertMessage = "帳號重覆"
                        break
                    case "fail":
                        doAlert = true
                        alertMessage = "申請失敗"
                        break
                    case "nice":
                        doAlert = true
                        self.buttonCount = 1
                        self.sendButton.setTitle("下一步", for: .normal)
                        alertMessage = "申請成功"
                        break
                    default:
                        break
                    }
                }
                
                if doAlert {
                    let alertControll = UIAlertController(title: "提示", message: alertMessage, preferredStyle: .alert)
                    let Okaction = UIAlertAction(title: "確定", style: .default, handler: nil)
                    alertControll.addAction(Okaction)
                    self.present(alertControll, animated: true,completion: nil)
                    
                }
                
                
            }, failure: {(error) -> Void in
                debugPrint(error)
            })
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
