//
//  AdviceViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/7/25.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit

class AdviceViewController: UIViewController {

    @IBOutlet weak var adviceText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
self.navigationController?.navigationBar.isTranslucent = false
        
        adviceText.layer.borderColor = UIColor.black.cgColor
        adviceText.layer.borderWidth = 1
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func submit(_ sender: Any) {
        
        if adviceText.text.count > 0 {
           let connect = ConnectPhp()
            connect.feedBack(text: adviceText.text)
            connect.doConnect(success: { (json) in
                
            }) { (error) in
                
            }
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
