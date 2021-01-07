//
//  ForgotPasswordViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/23.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON

class ForgotPasswordViewController: UIViewController {
    let connect = ConnectPhp()
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var verfiyField: UITextField!
    @IBOutlet weak var newPwField: UITextField!
    var count = 0
    var btnResendView : UIView? = nil
    var newPWView : UIView? = nil
    var verfiyView : UIView? = nil
    var accoutnView : UIView? = nil
    var mailView : UIView? = nil
    
    var account = ""
    var mail = ""
    
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
       accoutnView =  stackView.arrangedSubviews[0]
       mailView =  stackView.arrangedSubviews[1]
       verfiyView =  stackView.arrangedSubviews[2]
       newPWView = stackView.arrangedSubviews[3]
       btnResendView = stackView.arrangedSubviews[4]
        
        verfiyView?.isHidden = true
        newPWView?.isHidden = true
        btnResendView?.isHidden = true
        
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(ProfileViewController.goBack))
        let navItem = UINavigationItem(title: "忘記密碼")
        navItem.leftBarButtonItem = lefbutton
        navBar.setItems([navItem], animated: false)
       
        // Do any additional setup after loading the view.
    }
    
    @objc func goBack(){
        let mainBoard = UIStoryboard(name: "Main", bundle: nil)
        var VC : UIViewController? =  nil
        
        VC = mainBoard.instantiateViewController(withIdentifier: "LoginView")
        
        self.present(VC!, animated: true, completion: nil)
    }
    
    
    @IBAction func submit(_ sender: Any) {
        if count == 0 {
            checkMail()
        }else if count == 1 {
            changeUserPassword()
        }
    }
    
    @IBAction func reSend(_ sender: Any) {
        checkMail()
    }
    
    func checkMail(){
        if (accountField.text?.count)! > 0 && (emailField.text?.count)! > 0 {
            account = (account == "") ? accountField.text! : account
            mail = (mail == "") ? emailField.text! : mail
            connect.changePassword(account: account, mail: mail)
            connect.doConnectString(success: { (result) in
                if result == "200" {
                    self.accoutnView?.isHidden = true
                    self.mailView?.isHidden = true
                    self.verfiyView?.isHidden = false
                    self.newPWView?.isHidden = false
                    self.btnResendView?.isHidden = false
                    self.count = 1
                    self.showDialog(message: "驗證碼已發送")
                }else if (result == "404"){
                    self.showDialog(message: "帳號或密碼錯誤")
                }
            }) { (error) in
                
            }
        }else {
            showDialog(message: "請勿留白")
        }
    }
    
    func changeUserPassword(){
        let verfiyCode = verfiyField.text
        let newPw = newPwField.text
        if (verfiyCode?.count)! > 0 && (newPw?.count)! > 0 {
            let encrpypt = DataEncrypt()
            let encyptPw = encrpypt.encode(data: newPw!)!
            connect.changePassword(account: account, oldPw: verfiyCode!, newPw: encyptPw)
            connect.doConnectString(success: { (result) in
                if result == "200" {
                   self.showDialog(message: "成功")
                }else {
                    self.showDialog(message: "請確認驗證碼是否正確")
                }
            }) { (error) in
                
            }
        }
    }
    
    func showDialog(message:String){
        let alertControll = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertControll.addAction(okAction)
        self.present(alertControll, animated: true, completion: nil)
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
