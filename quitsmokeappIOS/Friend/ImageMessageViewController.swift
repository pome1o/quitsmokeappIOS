//
//  ImageMessageViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/11.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON

class ImageMessageViewController: UIViewController {
    var data : MessageStruct? = nil
    var friendAccount = ""
    var dirPath = ""
    var realFilePath = ""
    var fileManager : FileManager?
    var mydb : MySQLite? = nil
    var hostAccount = ""
    var processDialog : LoadingAnimation? = nil
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var topicView: UITextView!
    @IBOutlet weak var replyView: UITextView!
    @IBOutlet weak var sendReply: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        makeTouchOutsideHide()
        fileManager = FileManager.default
        hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        mydb = MySQLite.sharedInstance
        processDialog = LoadingAnimation(view: self.view)
        processDialog?.prepareView()
        
        replyView.layer.borderWidth = 1
        replyView.layer.borderColor = UIColor.black.cgColor
        
        let friendName = mydb?.get_fritend_name(account: friendAccount)
        let uri = fileManager?.urls(for: .documentDirectory, in: .userDomainMask).first
        let dataPath = uri?.appendingPathComponent(friendAccount)
        
        dirPath = "\((dataPath?.path)!)"
        
        if friendName != "" {
            titleLabel.text = friendName
        }
        setupReply()
        setupTopic()
        if hostAccount == data?.from {
            setReplyBtnDisable()
        }
        setupImage()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        print("mydebug 1111")
    }
    
    func setupImage() {
        if data?.file_name != ""{
            realFilePath = dirPath + "/" + (data?.file_name)!
            do{
                let imageData = try Data(contentsOf: URL(fileURLWithPath: realFilePath))
                imgView.image = UIImage(data: imageData)
            }catch  {
                debugPrint(error)
            }
        }
    }
    
    func setupTopic(){
        topicView.text = "內容: \n\r" + (data?.message)!
    }
    
    func setupReply(){
       let replyMsg = mydb?.get_reply_message(topicId: (data?._id)!)
        if (replyMsg?.count)! > 0 {
            replyView.text = "回覆：\r\n" + (replyMsg?[0].message)!
        }
    }
    
    func setReplyBtnDisable(){
       sendReply.isEnabled = false
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
    
    @IBAction func sendReply(_ sender: Any) {
        print("CLICK")
        if Connectivity.isConnected() {
            replyAlert()
        }else{
            let alertConnect = UIAlertController(title: "提示", message: "請先開啟網路", preferredStyle: .alert)
            alertConnect.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertConnect, animated: true, completion: nil)
        }
    }
    
    func replyAlert(){
        let alertControll = UIAlertController(title: "請輸入", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let alertAction = UIAlertAction(title: "確定", style: .default,
                                        handler:
            {(action: UIAlertAction) -> Void in
                let textField = alertControll.textFields?.first
                if (textField?.text?.count)! > 0 {
                    self.sendMsgEvent(msg: (textField?.text)!)
                }
        })
        alertControll.addTextField { ( textField :UITextField) in}
        alertControll.addAction(alertAction)
        alertControll.addAction(cancelAction)
        self.present(alertControll, animated: true, completion: nil)
    }
    
    func sendMsgEvent(msg : String){
        let connect = ConnectPhp()
        let id = (data?._id)!
        processDialog?.setText(msg: "傳送中")
        processDialog?.playAnimating()
        connect.replyMessage(id: String(id), friendAccount: friendAccount, message: msg, hostAccount: hostAccount)
        connect.doConnect(success: {(json) -> Void in
            if json["issent"].string == "yes"{
                let messageId = String(json["id"].intValue)
                self.mydb?.add_message(id: messageId, reply_id: String((self.data?._id)!), msg: msg, type: "text", path: "", title: "", frome_who: self.hostAccount, to_who: self.friendAccount, timestamp: json["time"].string!, isdownload: 1)
                self.showAlert(message: "發送成功")
                self.setReplyBtnDisable()
            }else{
                self.showAlert(message: "失敗")
            }
            self.processDialog?.stopAnimating()
        }, failure: {(error)-> Void in
            debugPrint(error)
            self.processDialog?.stopAnimating()
        })
        
    }
    
    func showAlert(message : String){
        let alertAction = UIAlertAction(title: "確定", style: .default,
                                        handler:
            {(action: UIAlertAction) -> Void in
                
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let alertControll = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertControll.addAction(alertAction)
        alertControll.addAction(cancelAction)
        
        self.present(alertControll, animated: true, completion: nil)
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
