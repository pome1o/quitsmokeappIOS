//
//  ChangeProfileViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/24.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit

class ChangeProfileViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
   
    

    var fromVC = ""
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userAge: UITextField!
    @IBOutlet weak var userWeigh: UITextField!
    @IBOutlet weak var userPackage: UITextField!
    @IBOutlet weak var userPrice: UITextField!
    @IBOutlet weak var userPcs: UITextField!
    @IBOutlet weak var userSmokeYears: UITextField!
    @IBOutlet weak var userBeenSmoke: UITextField!
    var gender = "男"
    var type = 2
    var jobPosition = 0
    let job = ["電腦工程師","操作技術士","軍警消防","醫療人員","客戶服務","農林漁牧","行政總務","運輸物流"
    ,"設計師","餐飲業","老師","學生"]
    @IBOutlet weak var navBar: UINavigationBar!
    
    var mysql : MySQLite? = nil
    @IBOutlet weak var manBtn: UIButton!
    @IBOutlet weak var girlBtn: UIButton!
    @IBOutlet weak var smokerBtn: UIButton!
    @IBOutlet weak var notSmokeBtn: UIButton!
    @IBOutlet weak var jobPicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mysql = MySQLite.sharedInstance
        jobPicker.delegate = self
        jobPicker.dataSource = self
        navBar.isTranslucent = false
        makeTouchOutsideHide()
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(ChangeProfileViewController.goBack))
        let navItem = UINavigationItem(title: "基本資料")
        navItem.leftBarButtonItem = lefbutton
        navBar.setItems([navItem], animated: false)
        if fromVC != "register"{
            fetchData()
        }
       
        
        // Do any additional setup after loading the view.
    }
    
    //how many column
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return job.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return job[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        jobPosition = row
    }
    
    //點選外面讓鍵盤消失
    func makeTouchOutsideHide(){
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc
    func hideKeyBoard(){
        view.endEditing(true)
    }
    
    //更新按鈕
    @IBAction func update(_ sender: Any) {
        updateData()
        let mainBoard = UIStoryboard(name: "Main", bundle: nil)
        var VC : UIViewController? =  nil
        if fromVC == "register" {
            //go back login
            VC = mainBoard.instantiateViewController(withIdentifier: "LoginView")
        }else if fromVC == "profile" {
            //go back main
             VC = mainBoard.instantiateViewController(withIdentifier: "ProfileViewController")
        }
        
        let alertController = UIAlertController(title: "完成", message: "完成", preferredStyle: .alert)
        let actionBtn = UIAlertAction(title: "OK", style: .default) { (action) in
           self.present(VC!, animated: true, completion: nil)
        }
        alertController.addAction(actionBtn)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func goBack(){
        let mainBoard = UIStoryboard(name: "Main", bundle: nil)
        var VC : UIViewController? =  nil
        if fromVC == "register" {
            VC = mainBoard.instantiateViewController(withIdentifier: "LoginView")
            //go back login
        }else if fromVC == "profile" {
            //go back main
            VC = mainBoard.instantiateViewController(withIdentifier: "ProfileViewController")
        }
        self.present(VC!, animated: true, completion: nil)
    }
    
    //抽煙選擇
    @IBAction func radioSmokeType(_ sender: UIButton) {
        for i in 0...1 {
            if sender.tag == i + 101 {
                sender.isSelected = true
                switch sender.tag {
                case 101:
                    type = 0
                    break
                case 102:
                    type = 2
                    break
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 101) as! UIButton
            Btn.isSelected = false
        }
    }
    
    //性別選擇
    @IBAction func radioGender(_ sender: UIButton) {
        for i in 0...1 {
            if sender.tag == i + 201 {
                sender.isSelected = true
                switch sender.tag {
                case 201:
                    gender = "男"
                    break
                case 202:
                    gender = "女"
                    break
                default:
        
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 201) as! UIButton
            Btn.isSelected = false
        }
    }
    
    
    func fetchData(){
        userName.text = mysql?.get_app_data(key: KeyName().SQL_USER_NAME)
        userAge.text = mysql?.get_app_data(key: KeyName().SQL_USER_YEARS)
        userWeigh.text = mysql?.get_app_data(key: KeyName().SQL_USER_WEIGHT)
        userPackage.text = mysql?.get_app_data(key: KeyName().SQL_USER_PACKAGE)
        userPcs.text = mysql?.get_app_data(key: KeyName().SQL_USER_PCS)
        userPrice.text = mysql?.get_app_data(key: KeyName().SQL_PACKAGE_MONEY)
        userSmokeYears.text = mysql?.get_app_data(key: KeyName().SQL_USER_SMOKE_YEAR)
        userBeenSmoke.text = mysql?.get_app_data(key: KeyName().SQL_USER_QUITED)
        
        if mysql?.get_app_data(key: KeyName().SQL_USER_GENDER) != ""{
            gender = (mysql?.get_app_data(key: KeyName().SQL_USER_GENDER))!
            
            if gender == "男" {
                manBtn.isSelected = true
            }else{
                girlBtn.isSelected = true
            }
        }
        
        if mysql?.get_app_data(key: KeyName().SQL_USER_TYPE) != "" {
            type = Int((mysql?.get_app_data(key: KeyName().SQL_USER_TYPE))!)!
            if type == 0 {
                smokerBtn.isSelected = true
            }else {
                notSmokeBtn.isSelected = true
            }
        }
        
        if job.index(of:(mysql?.get_app_data(key: "_job"))!) != nil {
            jobPosition = job.index(of:(mysql?.get_app_data(key: "_job"))!)!
        }
        
    }
    
    func updateData(){
        
        let key = [KeyName().SQL_USER_NAME,KeyName().SQL_USER_YEARS,KeyName().SQL_USER_WEIGHT,KeyName().SQL_USER_PACKAGE,KeyName().SQL_USER_SMOKE_YEAR,KeyName().SQL_USER_QUITED,KeyName().SQL_USER_PCS,KeyName().SQL_PACKAGE_MONEY,KeyName().SQL_USER_GENDER,"_job","_type"]
        
        var value : [String] = [userName.text! , userAge.text!, userWeigh.text! , userPackage.text! , userSmokeYears.text! , userBeenSmoke.text! , userPcs.text! , userPrice.text! , gender , job[jobPosition] , String(type)]
        print("mydebug:\(type)")
        for i in 0...key.count-1 {
            mysql?.add_app_data(title: key[i], value: value[i])
        }
        mysql?.add_app_data(title: KeyName().SQL_SYNC_USER, value: "1")
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
