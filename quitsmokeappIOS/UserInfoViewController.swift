//
//  UserInfoViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/5/28.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class UserInfoTabViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
   
    
    
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var stackBtn: UIStackView!
    
    @IBOutlet weak var barCharView: BarChartView!
    @IBOutlet weak var btnWantSmoke: UIButton!
    @IBOutlet weak var btnSmoked: UIButton!
    @IBOutlet weak var newMsgTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    private let Dia_Mesge_array : [String] = ["不要再抽菸了", "抽菸有害身心健康",
    "加油 ! 一定可以戒菸的", "家人朋友的支持能使您更容易戒菸", "保護家人不受二手菸的傷害,趕快戒菸", "多運動能改善抽菸情況"]
    private let Dr_Msg_arr : [String] =
["分散注意力,可以去跑步 , 運動 或是 玩遊戲", "尋找代替品,可以大口喝水,咬很涼的口香糖,或是深呼吸", "尋找代替品 , 咬吸管,筆,或是牙籤"
    ];
    
    var mysql : MySQLite? = nil
    var connect : ConnectPhp? = nil
    var lastMessage : [MessageStruct] = []
    var hostAccount = ""
    var smokeNumber : [Int] = []
    var smokeHour : [Int] = []
    var ismokeAlert : UIAlertController? = nil
    var userSmokeNumber = 1
    var userSmokeHour = 0
    var myChart = MyChart()


    override func viewDidLoad() {
        super.viewDidLoad()
     
        mysql = MySQLite.sharedInstance
        connect = ConnectPhp()
        hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        
        newMsgTable.dataSource = self
        newMsgTable.delegate = self
        self.newMsgTable.register(UINib(nibName: "NewMsgTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "newMsgCell")
        self.newMsgTable?.tableFooterView = UIView()
        
        let rightbutton = UIBarButtonItem(title: "登出", style: .plain, target: self, action: #selector(UserInfoTabViewController.logOut))
        let navItem = UINavigationItem(title: "個人資訊")
        navItem.rightBarButtonItem = rightbutton
        navBar.setItems([navItem], animated: false)
        
        checkVersion()
          updateNotification()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        if mysql?.get_app_data(key: KeyName().SQL_USER_TYPE) == "0" {
            ismokeAlert = settingAlertView()
            barCharView.layer.borderWidth = 1
            barCharView.layer.borderColor = UIColor.black.cgColor
            stackBtn.isHidden = false
            barCharView.isHidden = false
        }else{
            stackBtn.isHidden = true
            barCharView.isHidden = true
        }
        
        
        if mysql?.get_app_data(key: KeyName().SQL_USER_TYPE) == "0"  {
            myChart = MyChart()
            showChart()
        }
        fetchLastMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showChart(){
        myChart.setLocalData(day: 6)
        myChart.show(view: barCharView)
        
    }
    
    //table view setting --------------------------------------
    //how manay content in one section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lastMessage.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : NewMsgTableViewCell = self.newMsgTable.dequeueReusableCell(withIdentifier: "newMsgCell") as! NewMsgTableViewCell
        let msgName = mysql?.get_fritend_name(account: lastMessage[0].from!)
        cell.newMsgTitle.text = lastMessage[0].from
        cell.newMsgName.text = msgName
        cell.newMsgType.text = "\(lastMessage[0].msg_type!) \(lastMessage[0].datetime!)"
        cell.newMsgContent.text = lastMessage[0].message
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) + 我按了")
    }
    
    //how manany sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //-------------------------------------------------------------
    //picker view delegate ----------------------------------------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return smokeNumber.count
        }
        return smokeHour.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            userSmokeNumber = smokeNumber[row]
        }
        userSmokeHour = smokeHour[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
                return String(smokeNumber[row])
        }
        return String(smokeHour[row])
    }
    
    func fetchLastMessage(){
        lastMessage = (mysql?.lastTime(type: 0, account:""))!
        newMsgTable.reloadData()
    }
    
    //登出
    @objc func logOut(){
        let alertControll = UIAlertController(title: "登出", message: "確定登出？\r\n 登出將清除資料", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        
        let okButton = UIAlertAction(title: "確定", style: .default) { (action) in
            self.cleanAll()
        }
        alertControll.addAction(cancelButton)
        alertControll.addAction(okButton)
        alertControll.modalPresentationStyle = .fullScreen
        self.present(alertControll, animated: true, completion: nil)
        
    }
    
    //刪除所有相關資料
    func cleanAll(){
        let uri = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = uri.first?.path
        let fileManager = FileManager.default
        let mysql = MySQLite.sharedInstance
        mysql?.closeDB()
        do{
            let directoryConetent = try fileManager.contentsOfDirectory(atPath: path!)
            if directoryConetent.count > 0{
                for itemPath in directoryConetent {
                    print(itemPath)
                    let fullPath = path! + "/\(itemPath)"
                    print(fullPath)
                   try fileManager.removeItem(atPath: fullPath)
                }
            }
        }catch let error as Error {
            debugPrint(error)
        }
        
         UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
         UserDefaults.standard.synchronize()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginView")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    //初始化 抽菸根數選擇
    func setUpSmokeArray(picker : UIPickerView){
        smokeNumber = []
        for i in 1...50 {
            smokeNumber.append(i)
        }
        
        smokeHour = []
        for i in 0...23 {
            smokeHour.append(i)
        }
        picker.reloadAllComponents()
    }
    
    //建立抽煙對話框
    func settingAlertView() -> UIAlertController {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.dataSource = self
        pickerView.delegate = self
        vc.view.addSubview(pickerView)
        
        //建立pickerView title
        let title = ["時","根數"]
        let labelWidth = pickerView.frame.width / CGFloat(pickerView.numberOfComponents)
        for i in 0...1 {
            let label = UILabel(frame: CGRect(x: pickerView.frame.origin.x + labelWidth * CGFloat(i), y: 0, width: labelWidth, height: 20))
            label.text = title[i]
            label.textAlignment = .center
            pickerView.addSubview(label)
        }
        
        let alertVC = UIAlertController(title: "請選擇抽菸時間及數量", message: "請選擇", preferredStyle: .alert)
        alertVC.setValue(vc, forKey: "contentViewController")
        
        let okAction = UIAlertAction(title: "完成", style: .default) { (action) in
            let account = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)
            let formate = DateFormatter()
            formate.dateFormat = "yyyy-MM-dd"
            let toDate = Date()
            let dateString = formate.string(from: toDate)
            let time = "\(self.userSmokeHour):00:00"
            
            self.mysql?.add_smoke_record(account: account!, date: dateString, time: time, count: self.userSmokeNumber)
            self.mysql?.update_smoke_day(account: account!, time: time)
            self.mysql?.add_app_data(title: KeyName().SQL_SYNC_SMOKE, value: "1")
            self.showChart()
            
            if Connectivity.isConnected() {
                let friendList = self.mysql?.get_all_friend_list()
                if (friendList?.count)! > 0 {
                    self.connect?.iSmoke(account:self.hostAccount, list: friendList!)
                    self.connect?.doConnect(success: { (json) in
                        
                    }, failure: { (error) in
                        debugPrint(error)
                    })
                }
            }
            let randomIndex = Int(arc4random_uniform(UInt32(self.Dia_Mesge_array.count)))
            
            let tipsAlertVC = UIAlertController(title: "提示", message: self.Dia_Mesge_array[randomIndex], preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            tipsAlertVC.addAction(cancelAction)
            self.present(tipsAlertVC, animated: true, completion: nil)
            
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        setUpSmokeArray(picker: pickerView)
        return alertVC
    }
    
    @IBAction func wantSmoke(_ sender: Any) {
        if Connectivity.isConnected() {
           let friendList = mysql?.get_all_friend_list()
            if (friendList?.count)! > 0 {
                connect?.wantSmoke(account:hostAccount, list: friendList!)
                connect?.doConnect(success: { (json) in
                    
                }, failure: { (error) in
                    debugPrint(error)
                })
            }
        }
        let randomIndex = Int(arc4random_uniform(UInt32(self.Dr_Msg_arr.count)))
        let tipsAlertVC = UIAlertController(title: "提示", message: self.Dr_Msg_arr[randomIndex], preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        tipsAlertVC.addAction(cancelAction)
        self.present(tipsAlertVC, animated: true, completion: nil)
    }
    
    @IBAction func ismoke(_ sender: Any) {
        self.present(ismokeAlert!, animated: true, completion: nil)
    }
    
    @IBAction func testDB(_ sender: Any) {
        mysql?.testData()
    }
    
    
    func checkVersion() {
        let userDe = UserDefaults.standard
        let app_version = KeyName().APP_VERSION;
        var sp_version = userDe.string(forKey:  KeyName().SHARE_NEW_VERSION)
        if (sp_version == nil) {
            userDe.set(app_version, forKey: KeyName().SHARE_NEW_VERSION)
            userDe.set( "2017/10/6",forKey: KeyName().RELEASE_TIME)
            sp_version = app_version;
        }
        if (Connectivity.isConnected()) {
            let connect = ConnectPhp()
            connect.checkVersion()
            connect.doConnect(success: {(json)  in
                var version = ""
                if json != JSON.null {
                    version = json["version"].string!
                    userDe.set(version, forKey: KeyName().SHARE_NEW_VERSION)
                    userDe.set(json["time"].string!, forKey: KeyName().RELEASE_TIME)
                    userDe.set(json["note"].string!, forKey: KeyName().RELEASE_NOTE)
                    print("mydebug\(version)")
                    if(version != KeyName().APP_VERSION){
                        self.versionDialog()
                    }
                }
            }, failure: {(error) in
                print("mydebug\(error)")
            })
        }else{
            if(sp_version != app_version){
                versionDialog()
            }
        }
        
    }
    
    func versionDialog(){
        let userDe = UserDefaults.standard
        let message = "目前版本:\(KeyName().APP_VERSION) \n 新版本：\(userDe.string(forKey: KeyName().SHARE_NEW_VERSION)!) \n 更新日期：\(userDe.string(forKey: KeyName().RELEASE_TIME)!) \n 更新日誌：\(userDe.string(forKey: KeyName().RELEASE_NOTE)!)"
        
        let versionDialog = UIAlertController(title: "新版本", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        versionDialog.addAction(okAction)
        self.present(versionDialog, animated: true, completion: nil)
    }
    
    
    func updateNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: Notification.Name("updateMain"), object: nil)
    }
    
    @objc
    func updateData(){
        fetchLastMessage()
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


