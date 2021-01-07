//
//  FriendListViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/1.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON

class FriendListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var friendAccount = ""
    var friendArray : [FriendStruct] = []
    var mysql : MySQLite? = nil
    var connect : ConnectPhp? = nil;
    var hostAccount  = ""
    @IBOutlet weak var fieldAccount: UITextField!
    @IBOutlet weak var friendListTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        addNavigationItem()
        mysql = MySQLite.sharedInstance
        hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        connect = ConnectPhp()

        friendListTable.dataSource = self
        friendListTable.delegate = self
        self.friendListTable.register(UINib(nibName: "FriendListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "friendListCell")
        self.friendListTable?.tableFooterView = UIView()
        addLongPressRecognize()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        getFriendList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toInviteList(_ sender: Any) {
        self.performSegue(withIdentifier: "friendListToInvite", sender: nil)
    }
    
    @IBAction func addFriend(_ sender: Any) {
        if (fieldAccount.text?.count)! > 5 &&  fieldAccount.text != hostAccount  {
            connect?.addFriend(hostAccount: hostAccount, friendAccount: fieldAccount.text!)
            connect?.doConnect(
                success: {(respon) -> Void in
                    if respon != JSON.null {
                        let status = respon["ck"].string
                        switch status {
                        case "add_work":
                            self.alertShow(message: "邀請成功")
                            self.mysql?.add_friend(friend_id: self.fieldAccount.text!, friend_name: "", type: "-1")
                            self.fieldAccount.text! = ""
                            self.getFriendList()
                            break
                        default:
                            break
                        }
                    }else{
                        
                    }
            },
                failure:{ (error) -> Void in
                    
            })
            
        }else{
            alertShow(message: "帳號小於六碼或和自己帳號一樣")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : FriendListTableViewCell = self.friendListTable.dequeueReusableCell(withIdentifier: "friendListCell") as! FriendListTableViewCell
        
        
        cell.friendName.text = friendArray[indexPath.row].user_name
        
        if friendArray[indexPath.row].type == (Int)("0") {
            cell.friendImage.image = UIImage(named: "ismoke")
        }else{
            cell.friendImage.image = UIImage(named: "hospital")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.friendAccount = friendArray[indexPath.row].account!
        self.performSegue(withIdentifier: "friendListToMessage", sender: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //新增左上按鈕
    func addNavigationItem(){
        let homeButton = UIBarButtonItem(title: "功能頁", style: .plain, target: self, action: #selector(goBackToFunc))
        self.navigationItem.leftBarButtonItem = homeButton
    }
    
    //回上一頁事件
    @objc func goBackToFunc(_ sender : AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    
    //新增判斷長案
    func addLongPressRecognize(){
        let longRecognize = UILongPressGestureRecognizer(target: self, action: #selector(doLongPress))
        longRecognize.minimumPressDuration = 1.0
        self.view.addGestureRecognizer(longRecognize)
    }
    
    //長案要做的事
    @objc func doLongPress(recognizer: UILongPressGestureRecognizer){
        if recognizer.state == UIGestureRecognizerState.began{
            let tochPoint = recognizer.location(in: self.friendListTable)
            if let indexPath = friendListTable.indexPathForRow(at: tochPoint){
                let alertAction = UIAlertAction(title: "確定", style: .default,
                    handler:
                    {(action: UIAlertAction) -> Void in
                        self.deleteFriend(friendAccount: self.friendArray[indexPath.row].account!,position: indexPath.row)
                })
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                let alertControll = UIAlertController(title: "刪除", message: "確定刪除？", preferredStyle: .alert)
                alertControll.addAction(alertAction)
                alertControll.addAction(cancelAction)
                
                self.present(alertControll, animated: true, completion: nil)
            }
        }
    }
    
    func deleteFriend(friendAccount : String,position: Int){
        connect?.deleteFriend(hostAccount: hostAccount, friendAccount: friendAccount)
      
        connect?.doConnect(
            success: {(respon) -> Void in
                self.mysql?.del_friend(friend_id: friendAccount)
                self.deleteFriendItem(account: friendAccount)
                self.friendArray.remove(at: position)
                self.friendListTable.reloadData()
                
        }, failure:{ (error) -> Void in
            
        })
    }
    
    func deleteFriendItem(account : String){
        mysql?.delet_item(account: account)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "friendListToMessage" {
            let friendVC = segue.destination as! FriendTabBarController
            friendVC.friendAccount = self.friendAccount
        }
    }
    
    //Get list from sqlite
    func getFriendList(){
        let mydb = MySQLite.sharedInstance
        friendArray =  (mydb?.get_friend_by_order())!
        friendListTable.reloadData()
    }
    
    
    func alertShow(message : String){
        let alertAction = UIAlertAction(title: "確定", style: .default,
                                        handler:{(action: UIAlertAction) -> Void in
                                            
        })
        let alertControll = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertControll.addAction(alertAction)
        
        self.present(alertControll, animated: true, completion: nil)
        
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
