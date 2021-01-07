//
//  SendSoundMessageViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/2.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SendSoundMessageViewController: UIViewController {
    
    var friendAccount = ""
    var hostAccount = ""
    let url = "http://120.96.63.55/quit/upload.php"
    var recordManager : SoundRecordManager? = nil
    var timer : Timer? = nil
    var loadingAnimation : LoadingAnimation? = nil
    var isRecording = false
    
    @IBOutlet weak var timerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let friendBar = tabBarController as! FriendTabBarController
        self.friendAccount = friendBar.friendAccount
        self.navigationController?.navigationBar.isTranslucent = false
        hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        
        recordManager = SoundRecordManager(friendAccount: friendAccount)
        recordManager?.setupRecord()
        loadingAnimation = LoadingAnimation(view: self.view)
        loadingAnimation?.prepareView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startRecord(_ sender: Any) {
        recordManager?.startRecord()
        if !isRecording {
            isRecording = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func stopRecord(_ sender: Any) {
        recordManager?.stopRecord()
        stopTimer()
    }
    
    @IBAction func startPlay(_ sender: Any) {
        recordManager?.playSound()
    }
    
    @IBAction func stopPlay(_ sender: Any) {
        recordManager?.stopPlay()
        
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if !isRecording && (recordManager?.haveRecord())!{
            if Connectivity.isConnected(){
                uploadMessage()
            }else{
                let alertConnect = UIAlertController(title: "提示", message: "請先開啟網路", preferredStyle: .alert)
                alertConnect.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertConnect, animated: true, completion: nil)
            }
        }
    }
    
    var timeCount = 0
    @objc func stopRecording(){
        timeCount = timeCount + 1
        timerLabel.text = String(timeCount)
        if timeCount == 10 {
            recordManager?.stopRecord()
            stopTimer()
            timeCount = 0
        }
    }
    
    func stopTimer(){
        timerLabel.text = "停止錄音"
        isRecording = false
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func uploadMessage(){
        
        loadingAnimation?.playAnimating()
        let msg = "沒有文字"
        var parameters = JSON(["friend_account" : friendAccount,"my_account" : hostAccount,"message" : msg])
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if (self.recordManager?.haveRecord())!{
                multipartFormData.append(URL(fileURLWithPath: (self.recordManager?.getRecordPath())!), withName: "uploadedfile", fileName: "temp.m4a", mimeType: "audio/m4a")
            }
            multipartFormData.append((parameters.rawString()?.data(using: .utf8))!, withName: "job" )
            
        }, to: url,
           encodingCompletion:{ encodingResult in
            var alertMessage = ""
            switch encodingResult {
            case .success(let upload,_,_):
                upload.responseJSON(completionHandler:  { respons in
                    print(respons.result.value!)
                    
                    var json = JSON(respons.result.value!)
                    if json["issent"].string == "yes" {
                        let mysql = MySQLite.sharedInstance
                        mysql?.add_message(id: String(json["id"].intValue), reply_id: "0", msg: msg, type: json["type"].string!, path: json["file_name"].string!, title: "給好友的訊息", frome_who: self.hostAccount, to_who: self.friendAccount, timestamp: json["time"].string!, isdownload: 1)
                        self.recordManager?.copyFile(fileName: json["file_name"].string!)
                        alertMessage = "成功"
                        self.alertShow(message: alertMessage)
                        self.loadingAnimation?.stopAnimating()
                    }
                })
            case .failure(let encodingError):
                alertMessage = "失敗"
                self.alertShow(message: alertMessage)
                self.loadingAnimation?.stopAnimating()
                debugPrint(encodingError)
            }
        })
        
    }
    
    func alertShow(message : String){
        let alertAction = UIAlertAction(title: "確定", style: .default,
                                        handler:{(action: UIAlertAction) -> Void in
                                            
        })
        let alertControll = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertControll.addAction(alertAction)
        
        self.present(alertControll, animated: true, completion: nil)
    }
    
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
