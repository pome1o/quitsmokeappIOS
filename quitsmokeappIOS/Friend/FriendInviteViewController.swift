//
//  FriendInviteViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/3.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON


class FriendInviteViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    

    @IBOutlet weak var inviteTable: UITableView!
    var hostAccount = ""
    var friendArray : [FriendStruct] = []
    var connect : ConnectPhp? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        self.connect = ConnectPhp()
        
        
        inviteTable.delegate = self
        inviteTable.dataSource = self
        
        self.inviteTable.register(UINib(nibName: "FriendInviteTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "friendInviteCell")
        self.inviteTable.tableFooterView = UIView()
        self.inviteTable.allowsSelection = false
        self.inviteTable.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchInvite()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FriendInviteTableViewCell = self.inviteTable.dequeueReusableCell(withIdentifier: "friendInviteCell") as! FriendInviteTableViewCell
        cell.contentView.isUserInteractionEnabled = true
        cell.friendName.text = friendArray[indexPath.row].account
        cell.inviteConfirm.tag = indexPath.row
        cell.inviteReject.tag = indexPath.row
        cell.inviteConfirm.addTarget(self, action: #selector(confirmFriend), for: .touchUpInside)
        cell.inviteReject.addTarget(self, action: #selector(rejectFriend), for: .touchUpInside)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func fetchInvite(){
      
        connect?.fetchInvite(hostAccount: hostAccount)
        connect?.doConnect(
            success: { (respon) -> Void in
                
                if respon["ck"] == "ok"{
                    for i in 0...respon["name"].count-1 {
                        self.friendArray.append(FriendStruct(account: respon["data"][i].string, user_name: respon["name"][i].string, new_message: 0, type: Int(respon["user_type"][i].string!)))
                    }
                    self.inviteTable.reloadData()
                    
                }else{
                    
                }
        },
            failure: { (error) -> Void in
               
        })
    }
    
     @IBAction func confirmFriend(_ sender : AnyObject){
        
        let friendData = friendArray[sender.tag]
        
        connect?.confirmInvite(hostAccount: hostAccount, friendAccount: friendData.account!)
        connect?.doConnect(
            success:{ (respon) -> Void in
                
                if respon["ck"] == "update work" {
                    
                    let mydb = MySQLite.sharedInstance
                    mydb?.add_friend(friend_id: friendData.account!, friend_name: friendData.user_name!, type: String(friendData.type!))
                    self.friendArray.remove(at: sender.tag)
                    self.inviteTable.reloadData()
                    self.alert(alertMessage: "新增成功")
                }else{
                    
                }
                
        },
            failure:{ (error) -> Void in
                
        })
        
    }
    
     @IBAction func rejectFriend(_ sender: AnyObject){
        let friendData = friendArray[sender.tag]
        
        connect?.confirmInvite(hostAccount: hostAccount, friendAccount: friendData.account!)
        connect?.doConnect(
            success:{ (respon) -> Void in
                
                if respon["ck"] == "delete work" {
                    self.friendArray.remove(at: sender.tag)
                    self.inviteTable.reloadData()
                    self.alert(alertMessage: "拒絕成功")
                    
                }else{
                    
                }
        },
            failure:{ (error) -> Void in
                
        })
    }
    
    func alert(alertMessage: String){
        let alertAction = UIAlertAction(title: "確定", style: .default,
                                        handler:{(action: UIAlertAction) -> Void in
                                            
        })
        let alertControll = UIAlertController(title: "提示", message: alertMessage, preferredStyle: .alert)
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
