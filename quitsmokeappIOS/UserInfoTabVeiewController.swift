//
//  UserInfoTabViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/5/21.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit

class UserInfoTabViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var btnWantSmoke: UIButton!
    @IBOutlet weak var btnSmoked: UIButton!
    @IBOutlet weak var newMsgTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newMsgTable.dataSource = self
        newMsgTable.delegate = self
        self.newMsgTable?.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //how manay content in one section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UserInfoTableCell = self.newMsgTable.dequeueReusableCell(withIdentifier: "Cell") as! UserInfoTableCell
        //cell.new_msg_title.text = "title"
        cell.new_msg_name.text = "name"
        cell.new_msg_type.text = "type"
        cell.new_msg_content.text = "內容"
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
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class UserInfoTableCell : UITableViewCell {
    @IBOutlet weak var new_msg_title: UILabel!
    @IBOutlet weak var new_msg_name: UILabel!
    @IBOutlet weak var new_msg_content: UILabel!
    @IBOutlet weak var new_msg_type: UILabel!
}
