//
//  connectPhp.swift
//  testphp
//
//  Created by OITMIB on 2018/3/24.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ConnectPhp {
    
    private let serverIp : String = "http://192.168.1.105:8000/"
    private let GET_KEY = "friend_method="
    private let FRIEND_URL = "friendship.php?"
    private var parameters : Parameters!
    private var url : String!
    private let KEY_ACCOUNT = "my_account"
    private let KEY_FRIEND_ACCOUNT = "friend_account"
    private let KEY_MESSAGE = "message"
    private let KEY_PASSWORD = "password"
    private let KEY_USER_NAME = "user_name"
    private let KEY_USER_TYPE = "user_type"
    private let KEY_MAIL = "email"
    private let KEY_TOKEN = "fcm_token"
    
    
    func login(user_name : String , password : String) {
        setUrl(url: serverIp + "login/")
        
        self.parameters = [KEY_ACCOUNT : user_name , "password" : password]
    }
    
    func registered_user(account : String, password : String, name : String, mail : String, type : Int){
        setUrl(url: serverIp + "add.php")
        self.parameters = [KEY_ACCOUNT:account,KEY_PASSWORD:password,KEY_USER_NAME:name,KEY_MAIL:mail,KEY_USER_TYPE:type]
    }
    
    func addFriend(hostAccount : String,friendAccount : String){
        setUrl(url: serverIp + FRIEND_URL + GET_KEY + "addfriend")
        self.parameters = [KEY_ACCOUNT:hostAccount,KEY_FRIEND_ACCOUNT :friendAccount]
    }
    
    func deleteFriend(hostAccount : String, friendAccount: String){
        setUrl(url: serverIp + FRIEND_URL + GET_KEY + "delete_supporter")
        self.parameters = [KEY_ACCOUNT : hostAccount,KEY_FRIEND_ACCOUNT : friendAccount]
    }
    
    func fetchInvite(hostAccount : String){
        setUrl(url: serverIp + FRIEND_URL + GET_KEY + "supporter_request")
        self.parameters = [KEY_ACCOUNT : hostAccount]
    }
    
    func rejectInvite(hostAccount : String, friendAccount : String){
        setUrl(url: serverIp + FRIEND_URL + GET_KEY + "refuse")
        self.parameters = [KEY_ACCOUNT : hostAccount,KEY_FRIEND_ACCOUNT : friendAccount]
    }
    
    func confirmInvite(hostAccount : String, friendAccount : String){
        setUrl(url: serverIp + FRIEND_URL + GET_KEY + "accept")
        self.parameters = [KEY_ACCOUNT : hostAccount , KEY_FRIEND_ACCOUNT : friendAccount]
    }
    
    func getFriendGraph(friendAccount :String ,date :String , interval :Int){
        setUrl(url: serverIp + "getsmokedata_swift.php")
        self.parameters = ["account" : friendAccount, "date":date, "interval" : interval]
    }
    
    func loadSmoke(account : String){
        setUrl(url: serverIp + "downloadsmokedata_swift.php")
        self.parameters = ["account" : account]
    }
    
    func replyMessage(id : String , friendAccount : String ,message : String , hostAccount : String){
        setUrl(url: serverIp + "upload.php?reply=1")
        self.parameters = [KEY_ACCOUNT: hostAccount,KEY_FRIEND_ACCOUNT:friendAccount,"id":id,KEY_MESSAGE:message]
    }
    
    func upDateUserInfo(account : String ,dataKey : [String], dataValue : [String]){
        setUrl(url: serverIp + "update_user.php")
        self.parameters = [KEY_ACCOUNT : account, "data_name": dataKey,"data_value": dataValue]
    }
    
    func upload_smoke(account : String , date : String ,time : String){
        setUrl(url: serverIp + "upload_smoke_record.php")
        self.parameters = ["account" :account,"date":date,"time":time]
    }
    
    func getMessageFromServer(account : String , lastTime : String){
        setUrl(url: serverIp + "syncmessage.php")
        self.parameters = [KEY_ACCOUNT:account,"_time" : lastTime]
    }
    
    func syncFriend(account :String){
        setUrl(url: serverIp + FRIEND_URL + GET_KEY + "sponsor_list")
        self.parameters = [KEY_ACCOUNT : account]
    }
    
    func checkSync(account : String){
        setUrl(url: serverIp + "checkSync.php")
        self.parameters = [KEY_ACCOUNT : account,"mod":"get"]
    }
    
    func sendToken(account : String,token : String){
        setUrl(url: serverIp + "fcm_token.php")
        //fcm_token.php
        self.parameters = [KEY_ACCOUNT : account,KEY_TOKEN : token]
    }
    
    func changeSync(account : String,status : String){
        setUrl(url: serverIp + "checkSync.php")
        self.parameters = [KEY_ACCOUNT : account,"mod":"change","data":status]
    }
    
    func wantSmoke (account : String,list :[FriendStruct]){
        setUrl(url: serverIp + "ismoke.php?wantsmoke=1")
        var tempArray : [String] = []
        for i in 0...list.count-1 {
            tempArray.append(list[i].account!)
        }
        self.parameters = [KEY_ACCOUNT : account,"friend_account":tempArray,"size":tempArray.count]
    }
    
    func iSmoke (account : String,list :[FriendStruct]){
        setUrl(url: serverIp + "ismoke.php")
        var tempArray : [String] = []
        for i in 0...list.count-1 {
            tempArray.append(list[i].account!)
        }
        self.parameters = [KEY_ACCOUNT : account,"friend_account":tempArray,"size":tempArray.count]
    }
    
    func sendVerfiy(mail :String ,account: String,rebool : String, mod : String){
        setUrl(url: serverIp + "verifymail/sendverify")
        self.parameters = [KEY_MAIL : mail,"account" : account,"resend":rebool,"mod":mod]
    }
    
    func checkVersion(){
        setUrl(url: serverIp + "checkversion.php")
        self.parameters = ["device":"ios"]
    }
    
    func feedBack(text : String){
        setUrl(url: serverIp + "user_feedback.php")
        self.parameters = ["sdk_version":"ios","brand":"apple","feedback":text]
    }
    
    func changePassword(account : String, mail : String){
        setUrl(url: serverIp + "forgotpassword.php")
        self.parameters = ["account":account,"mail":mail]
    }
    
    func changePassword(account : String, oldPw : String, newPw : String){
        setUrl(url: serverIp + "forgotpassword.php")
        self.parameters = ["account" : account,"oldPw" : oldPw,"newPassword" : newPw]
    }
    
    func getUrl() -> String {
        return self.url
    }
    
    private func setUrl(url : String){
        self.url = url
    }
    
    private func getParameters() -> Parameters{
        return self.parameters
    }
    
    func doConnect(success:@escaping(JSON) -> Void , failure:@escaping(Error) -> Void){
        Alamofire.request( getUrl() , method : .post , parameters :  getParameters() , encoding : URLEncoding.httpBody ).downloadProgress(queue: DispatchQueue.global(qos: .utility)){ progress in
            
            }
            .validate { request , response , data in
                return .success
            }
            .responseJSON{ (response) -> Void in
                
                if response.result.isSuccess {
                    let dataJson = JSON(response.result.value!)
                    success(dataJson)
                }
                
                if response.result.isFailure{
                    let error : Error = response.result.error!
                    failure(error)
                }
            }
    }
    
    func doConnectString(success:@escaping(String) -> Void, failure:@escaping(Error) -> Void){
        Alamofire.request(getUrl(), method: .post, parameters: getParameters(), encoding: URLEncoding.httpBody).downloadProgress(queue: DispatchQueue.global(qos: .utility)){
            progress in
        }
            .validate { request, response , data in
                return .success
        }
            .responseString { (response) -> Void in
                if response.result.isSuccess {
                    success(response.result.value!)
                }
                
                if response.result.isFailure {
                    let error : Error = response.result.error!
                    failure(error)
                }
        }
    }
}
