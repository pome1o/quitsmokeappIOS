//
//  FriendGraphViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/2.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class FriendGraphViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var alertController : UIAlertController? = nil
    var friendAccount = ""
    var myChart = MyChart()
    let calendar = Calendar.current
    var connection : ConnectPhp? = nil
    var formatter : DateFormatter? = nil
    var loadanimation : LoadingAnimation? = nil
    
   
    
    @IBOutlet weak var labelDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAlert()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBar = tabBarController as! FriendTabBarController
        self.friendAccount = tabBar.friendAccount
        connection = ConnectPhp()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //labelDetail.text = myChart.detailText()
        formatter = DateFormatter()
        formatter?.dateFormat = "yyyy-MM-dd"
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "zh_TW")
        datePicker.maximumDate = Date()
        loadanimation = LoadingAnimation(view: self.view)
        loadanimation?.prepareView()
        loadanimation?.setText(msg: "讀取資料中")
    }
    
    @IBAction func searchSmoke(_ sender: Any) {
        self.present(alertController!,animated: true,completion: nil)
    }
    
    func setupAlert(){
         alertController = UIAlertController(title: "選擇", message: "請選擇區段", preferredStyle: .alert)
        let todyAction = UIAlertAction(title: "今天", style: .default, handler: {(action: UIAlertAction) -> Void in
            self.fetchData(day: 0)
        })
        
        let monthAction = UIAlertAction(title: "月", style: .default, handler: {(action: UIAlertAction) -> Void in
             self.fetchData(day: 34)
        })
        
        let weekAction = UIAlertAction(title: "週", style: .default, handler: {(action: UIAlertAction) -> Void in
             self.fetchData(day: 6)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController?.addAction(todyAction)
        alertController?.addAction(weekAction)
        alertController?.addAction(monthAction)
        alertController?.addAction(cancelAction)
    }
    
    func fetchData(day :Int){
        loadanimation?.playAnimating()
        let dateTime = formatter?.string(from: datePicker.date)
        
        connection?.getFriendGraph(friendAccount: friendAccount, date: dateTime!, interval: day)
        connection?.doConnect(
            success: {(respon) -> Void in
      
                var count : [Double] = []
                for (i,json) : (String,JSON) in respon["friend_select_count"]{
                    count.append(Double(json.intValue))
                }
                let dateComponents = self.calendar.dateComponents([.year,.month,.day], from: self.datePicker.date)
                self.myChart.setDate(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
                self.myChart.setData(data: count, day: day)
                self.myChart.show(view: self.barChartView)
                self.loadanimation?.stopAnimating()
        },
            failure: {(error) -> Void in
                debugPrint(error)
                self.loadanimation?.stopAnimating()
        })
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
