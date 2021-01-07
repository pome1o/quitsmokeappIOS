//
//  AppAboutViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/7/25.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit

class AppAboutViewController: UIViewController {

    @IBOutlet weak var messageView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        let userDe = UserDefaults.standard
        
        //get data from userdefault
        let text = "最新版本：\(userDe.string(forKey: KeyName().SHARE_NEW_VERSION)!) \n 新版本釋出時間：\(userDe.string(forKey: KeyName().RELEASE_TIME)!) \n 您的版本：\(KeyName().CURRENT_VERSION)"
        
        messageView.text = text
        // Do any additional setup after loading the view.
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
