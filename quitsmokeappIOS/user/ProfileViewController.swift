//
//  ProfileViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/7/1.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var mail: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(ProfileViewController.goBack))
        let navItem = UINavigationItem(title: "個人資料")
        navItem.leftBarButtonItem = lefbutton
        navBar.setItems([navItem], animated: false)
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToChange" {
            let changeVC = segue.destination as! ChangeProfileViewController
            changeVC.fromVC = "profile"
        }
    }
    
    func fetchData(){
        let mysql = MySQLite.sharedInstance
        account.text = mysql?.get_app_data(key: KeyName().SHARE_ACCOUNT)
        name.text = mysql?.get_app_data(key: KeyName().SQL_USER_NAME)
        year.text = mysql?.get_app_data(key: KeyName().SQL_USER_YEARS)
       
        mail.text = mysql?.get_app_data(key: KeyName().SQL_USER_EMAIL)
    }
    
    
    
    @objc func goBack(){
        let mainBoard = UIStoryboard(name: "Main", bundle: nil)
        var VC : UIViewController? =  nil

            VC = mainBoard.instantiateViewController(withIdentifier: "MainViewController")

        self.present(VC!, animated: true, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goChange(_ sender: Any) {
        self.performSegue(withIdentifier: "profileToChange", sender: nil)
    }
    
    @IBAction func checkMail(_ sender: Any) {
        let mailVerify = CheckVerify(view: self)
        print(Connectivity.isConnected())
        if Connectivity.isConnected() {
            mailVerify.showAlert()
        }else{
            let alertControl = UIAlertController(title: "提示", message: "請先開啟網路", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertControl.addAction(okAction)
            self.present(alertControl, animated: true, completion: nil)
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
