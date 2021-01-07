//
//  SendMessageViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/2.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView


class SendMessageViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate,UITextViewDelegate{

    @IBOutlet weak var textPlain: UITextView!
    @IBOutlet weak var imageShow: UIImageView!
    
    var friendAccount = ""
    var fileName = ""
    var realPath = ""
    var dirPath = ""
    var hostAccount = ""
    let url = "http://120.96.63.55/quit/upload.php"
    var fileMananger : FileManager? = nil
    var imageToSend : UIImage? = nil
    var loadingView : UIView?
    var loadingAnimation : LoadingAnimation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hostAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)!
        textPlain.delegate = self
        textPlain.layer.borderColor = UIColor.gray.cgColor
        textPlain.layer.borderWidth = 1
        textPlain.text = "請在這輸入文字/可選圖片或不選"
        textPlain.textColor = .gray
        imageShow.layer.borderWidth = 1
        imageShow.layer.borderColor = UIColor.gray.cgColor
        imageShow.backgroundColor = .gray
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let friendTabBar = tabBarController as! FriendTabBarController
        friendAccount = friendTabBar.friendAccount
        fileMananger = FileManager.default
        let uri = fileMananger?.urls(for: .documentDirectory, in: .userDomainMask).first
        let dataPath = uri?.appendingPathComponent(friendAccount)
        dirPath = (dataPath?.path)!
        loadingAnimation =  LoadingAnimation(view: self.view)
        loadingAnimation?.prepareView()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.view.endEditing(true)
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if(Connectivity.isConnected()){
            uploadMessage()
        }else{
            let alertConnect = UIAlertController(title: "提示", message: "請先開啟網路", preferredStyle: .alert)
            alertConnect.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertConnect, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickImage(_ sender: Any) {
        chooseAlbumOrCamera(type: 0)
    }
    
    @IBAction func openCamera(_ sender: Any) {
        chooseAlbumOrCamera(type: 1)
    }
    
    
    func checkDirEx(path : String){
        var isDir : ObjCBool = false
        if !(fileMananger?.fileExists(atPath: path, isDirectory: &isDir))! && !isDir.boolValue{
                do{
                    try fileMananger?.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                }catch let error as Error {
                    print(error.localizedDescription)
                }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textPlain.text = ""
        textPlain.textColor = .black
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        checkDirEx(path: dirPath)
        fileName = "temp" + ".jpg"
        realPath = dirPath + "/\(fileName)"
         imageToSend = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(imageToSend!, 1.0)
        fileMananger?.createFile(atPath: realPath, contents: imageData, attributes: nil)
        imageShow.image = imageToSend
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func copyFile(fileName:String){
        let newPath = dirPath + "/\(fileName)"
        do{
        try fileMananger?.copyItem(atPath: realPath, toPath: newPath)
        }catch let error {
            debugPrint(error)
        }
    }
    
    func uploadMessage(){
        var msg = "沒有文字"
        if textPlain.text.count > 0 && textPlain.text != "請在這輸入文字/可選圖片或不選"{
            msg = textPlain.text
        }
        loadingAnimation?.playAnimating()
        
        var parameters = JSON(["friend_account" : friendAccount,"my_account" : hostAccount,"message" : msg])
        
        var alertMessage = ""
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            //如果沒圖片不執行上傳圖片
            if self.imageToSend != nil {
                if let imageData = UIImageJPEGRepresentation(self.imageToSend!, 1.0){
                    multipartFormData.append(imageData, withName: "uploadedfile", fileName: "temp.jpg", mimeType: "image/jpeg")
                }
            }
            
            
            multipartFormData.append((parameters.rawString()?.data(using: .utf8))!, withName: "job" )
            
        }, to: url,
           encodingCompletion:{ encodingResult in
            
            switch encodingResult {
            case .success(let upload,_,_):
                upload.responseJSON(completionHandler:  { respons in
                    print(respons.result.value!)
                    let json = JSON(respons.result.value!)
                    if json["issent"].string == "yes" {
                        let mysql = MySQLite.sharedInstance
                        if self.imageToSend != nil {
                            mysql?.add_message(id: String(json["id"].intValue), reply_id: "0", msg: msg, type: json["type"].string!, path: json["file_name"].string!, title: "給好友的訊息", frome_who: self.hostAccount, to_who: self.friendAccount, timestamp: json["time"].string!, isdownload: 1)
                            self.copyFile(fileName: json["file_name"].string!)
                        }else{
                            mysql?.add_message(id: String(json["id"].intValue), reply_id: "0", msg: msg, type: json["type"].string!, path: "", title: "給好友的訊息", frome_who: self.hostAccount, to_who: self.friendAccount, timestamp: json["time"].string!, isdownload: 1)
                        }
                    }
                    alertMessage = "成功"
                    self.loadingAnimation?.stopAnimating()
                    self.alertShow(message: alertMessage)
                })
            case .failure(let encodingError):
                debugPrint(encodingError)
                alertMessage = "失敗"
                self.loadingAnimation?.stopAnimating()
                self.alertShow(message: alertMessage)
            }
            
        })
        
    }
    
    @IBAction func cancelImage(_ sender: Any) {
        if imageShow.image != nil {
            imageShow.image = nil
            imageToSend = nil
            realPath = ""
        }
    }
    
    func chooseAlbumOrCamera(type : Int){
        let picker = UIImagePickerController()
        
        switch type {

        case 1:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.delegate = self
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: {()-> Void in})
            }else{
                print("no camera")
            }
            break
        default:
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: {()-> Void in})
            }
            break
        }
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
