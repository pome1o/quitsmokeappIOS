//
//  AboutMainViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/7/23.
//  Copyright © 2018 OITMIB. All rights reserved.
//

//關於 主要頁面

import UIKit

class AboutMainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    var name = ["門診","團隊介紹","關於程式","給予建議","操作說明"]
    //segue id
    var path = ["aboutToDoor","aboutToTeam","aboutToAbout","aboutToAdvice","aboutToHow"]
    
    
    @IBOutlet weak var aboutTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        aboutTable.delegate = self
        aboutTable.dataSource = self
         self.aboutTable?.tableFooterView = UIView()
        addNavigationItem()
        // Do any additional setup after loading the view.
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
    
    //tableview content size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return name.count
    }
    //cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = aboutTable.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath)
        cell.textLabel?.text = name[indexPath.row]
        return cell
    }
    
    //click event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //change page
        self.performSegue(withIdentifier: path[indexPath.row], sender: nil)
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
