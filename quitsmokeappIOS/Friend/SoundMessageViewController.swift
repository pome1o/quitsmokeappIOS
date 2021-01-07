//
//  SoundMessageViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/11.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import AVFoundation

class SoundMessageViewController: UIViewController {
    var data : MessageStruct? = nil
    var friendAccount = ""
    let dirPath = ""
    var realFilePath = ""
    var fileManager : FileManager?
    var mydb : MySQLite? = nil
    var hostAccount = ""
    var processDialog : LoadingAnimation? = nil
    var musicPlayer : AVAudioPlayer? = nil
    
    @IBOutlet weak var replyView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var replyField: UITextField!
    @IBOutlet weak var replySendBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        fileManager = FileManager.default
        hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        mydb = MySQLite.sharedInstance
        processDialog = LoadingAnimation(view: self.view)
        processDialog?.prepareView()
        
        let uri = fileManager?.urls(for: .documentDirectory, in: .userDomainMask).first
        let dataPath = uri?.appendingPathComponent(friendAccount)
        realFilePath = "\((dataPath?.path)!)/" + (data?.file_name)!
        
        let friendName = mydb?.get_fritend_name(account: friendAccount)
        
        if friendName != "" {
            titleLabel.text = friendName
        }
        
        setupReply()
        
        if hostAccount == data?.from {
            setReplyBtnDisable()
        }
        setupMusicPlayer()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("mydebug:111")
        self.view.endEditing(true)
    }
    
    func setupReply(){
        let replyMsg = mydb?.get_reply_message(topicId: (data?._id)!)
        if (replyMsg?.count)! > 0 {
            replyView.text = "回覆：\r\n" + (replyMsg?[0].message)!
        }
    }
    
    func setReplyBtnDisable(){
        replyField.isEnabled = false
        replySendBtn.isEnabled = false
    }
    
    func setupMusicPlayer(){
        do{
            print(realFilePath)
            musicPlayer = AVAudioPlayer()
            musicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: realFilePath))
            musicPlayer?.prepareToPlay()
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        }catch let error {
            debugPrint(error)
        }
    }
    
    @IBAction func playMusic(_ sender: Any) {
        if musicPlayer != nil {
            musicPlayer?.play()
        }
    }
    
    @IBAction func stopMusic(_ sender: Any) {
        if musicPlayer != nil && (musicPlayer?.isPlaying)! {
            musicPlayer?.stop()
            musicPlayer?.currentTime = 0
        }
    }
    
    @IBAction func sendReply(_ sender: Any) {
        if Connectivity.isConnected(){
            sendEvent()
        }else{
            let alertConnect = UIAlertController(title: "提示", message: "請先開啟網路", preferredStyle: .alert)
            alertConnect.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertConnect, animated: true, completion: nil)
        }
    }
    
    func sendEvent(){
        let connect = ConnectPhp()
        
        if (replyField.text?.count)! <= 0 {
            self.showAlert(message: "請輸入")
            return
        }
        
        print("REPLY DATA \(data?._id)")
        let msg = replyField.text
        let id = String((data?._id)!)
        connect.replyMessage(id: id, friendAccount: friendAccount, message: msg!, hostAccount: hostAccount)
        connect.doConnect(success: {(json) -> Void in
            print("REPLY \(json)")
            if json["issent"].string == "yes"{
                let messageId = String(json["id"].intValue)
                self.mydb?.add_message(id: messageId, reply_id: id, msg: msg!, type: "text", path: "", title: "", frome_who: self.hostAccount, to_who: self.friendAccount, timestamp: json["time"].string!, isdownload: 1)
                self.showAlert(message: "發送成功")
                self.setReplyBtnDisable()
            }else{
                self.showAlert(message: "失敗")
            }
            self.processDialog?.stopAnimating()
        }, failure: {(error) -> Void in
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
