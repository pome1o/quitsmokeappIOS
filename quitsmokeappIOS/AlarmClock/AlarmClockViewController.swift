//
//  AlarmClockViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/28.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import UserNotifications

class AlarmClockViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    @IBOutlet weak var fireList: UITextView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var pickerNum : [String] = []
    var pickerNumSecond : [String] = []
    var timeFrom = 0
    var timeTo = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(AlarmClockViewController.goBack))
        let navItem = UINavigationItem(title: "定時提醒")
        navItem.leftBarButtonItem = lefbutton
        navBar.setItems([navItem], animated: false)
    
        
        pickerFrom.delegate = self
        pickerFrom.dataSource = self
        pickerTo.dataSource = self
        pickerTo.delegate = self
        fetchUserTime()
        setPickNum()
       
        
        printNotification()
        getAlarmTime()
        
        // Do any additional setup after loading the view.
        
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //btn click
    @IBAction func btnSet(_ sender: Any) {
        //AlarmClass
       let alarmClock = AlarmClock()
        alarmClock.cancelAlarm()
        //set from time
        alarmClock.setFrom(from: timeFrom)
        //to time
        alarmClock.setTo(to: timeTo)
        alarmClock.setUpNotification()
        UserDefaults.standard.set(timeFrom, forKey: KeyName().ALARM_FROM)
        UserDefaults.standard.set(timeTo,forKey: KeyName().ALARM_TO)
        getAlarmTime()
    }
    @IBAction func btnCancel(_ sender: Any) {
        let alarmClock = AlarmClock()
        alarmClock.cancelAlarm()
        getAlarmTime()
    }
    
    
    func setPickNum(){
        for i in 0...23{
            pickerNum.append(String(i))
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    //picker size
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == pickerFrom{
           return pickerNum.count
        }else if pickerView == pickerTo {
            return pickerNumSecond.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == pickerFrom{
            return pickerNum[row]
        }else if pickerView == pickerTo {
            return pickerNumSecond[row]
        }
        return ""
    }
    
    //did select
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("did select")
        if pickerView == pickerFrom {
            timeFrom = Int(pickerNum[row])!
            //dynamic change
            changeSeconPicker(from: timeFrom)
            if timeFrom == 23 {
                timeTo = 0
            }else{
                timeTo = timeFrom + 1
            }
        }else if pickerView == pickerTo {
             timeTo = Int(pickerNumSecond[row])!
        }
    }
    //change second picker data
    func changeSeconPicker(from : Int){
        pickerNumSecond = []
        var tempFrom = from
        if tempFrom < 23 {
            tempFrom = tempFrom + 1
        }
        for i in tempFrom...23 {
            pickerNumSecond.append(String(i))
        }
        pickerTo.reloadAllComponents()
    }
    
    
    func fetchUserTime(){
        let userDefault = UserDefaults.standard
      
        timeFrom = userDefault.integer(forKey: KeyName().ALARM_FROM)
        
        timeTo = userDefault.integer(forKey: KeyName().ALARM_TO)
        pickerFrom.reloadAllComponents()
        pickerTo.reloadAllComponents()
        pickerFrom.selectRow(timeFrom, inComponent: 0, animated: false)
        pickerTo.selectRow(timeTo, inComponent: 0, animated: false)
    }
    
    
    func getAlarmTime(){
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd H:mm:ss"
        dateFormat.locale = Locale.init(identifier: "zh_TW")
        var tempText : String = ""
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            for request in requests {
                let trigger =  request.trigger as! UNCalendarNotificationTrigger
                tempText = tempText + dateFormat.string(from: trigger.nextTriggerDate()!) + "\r\n"
            }
            let data : [String:String] = ["text":tempText]
            NotificationCenter.default.post(name:Notification.Name("PrintText") , object: nil,userInfo:data)
        }
    }
    
    func printNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(printTime(notification:)), name:Notification.Name("PrintText"), object: nil)
    }
    
    @objc
    func printTime(notification :Notification){
        DispatchQueue.main.async(execute: {
            self.fireList.text = notification.userInfo!["text"] as! String;
        })
       
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
