//
//  FriendMessageViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/2.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit

class FriendMessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var testFriend: UILabel!
    @IBOutlet weak var messageTable: UITableView!
    var data : MessageStruct? = nil
    var friendAccount = ""
    var messageArray : [MessageStruct] = []
    var mysql : MySQLite? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTable.delegate = self
        messageTable.dataSource = self
        self.navigationController?.navigationBar.isTranslucent = false
        messageTable.register(UINib(nibName: "FriendMessageTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "friendMessageCell")
        messageTable.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let friendTabBar = tabBarController as! FriendTabBarController
        friendAccount = friendTabBar.friendAccount
        testFriend.text = friendAccount
        mysql = MySQLite.sharedInstance
        fetchMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchMessage(){
        messageArray = (mysql?.get_message_by_order(account: friendAccount))!
        messageTable.reloadData()
    }
    
    //處理被案下
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.data = messageArray[indexPath.row]
        if messageArray[indexPath.row].msg_type == "audio"{
            
            self.performSegue(withIdentifier: "toSound", sender: self)
        }else{
            
             self.performSegue(withIdentifier: "toImage", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImage" {
            let imageVC = segue.destination as! ImageMessageViewController
            imageVC.data = self.data
            imageVC.friendAccount = self.friendAccount
            print("ImageView :toImage")
        }else if segue.identifier == "toSound" {
            let soundVC = segue.destination as! SoundMessageViewController
            soundVC.data = self.data
            soundVC.friendAccount = self.friendAccount
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : FriendMessageTableViewCell = self.messageTable.dequeueReusableCell(withIdentifier: "friendMessageCell") as! FriendMessageTableViewCell
        var data = messageArray[indexPath.row]
        cell.lbName.text = data.from
        cell.lbContent.text = data.message
        cell.lbTime.text = data.datetime
        cell.lbType.text = data.msg_type
        if data.from == friendAccount {
             cell.lbName.textColor = UIColor(displayP3Red: 81/255, green: 118/255, blue: 169/255, alpha: 1.0)
        }else{
            cell.lbName.text = "給對方的訊息"
           cell.lbName.textColor = UIColor(displayP3Red: 187/255, green: 113/255, blue: 97/255, alpha: 1.0)
        }
        var typeText = ""
        switch data.msg_type {
        case "audio":
            typeText = "有語音檔"
            break
        case "image":
            typeText = "有圖片"
            break
        default:
            cell.lbType.isEnabled = false
            break
        }
        cell.lbType.text = typeText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
