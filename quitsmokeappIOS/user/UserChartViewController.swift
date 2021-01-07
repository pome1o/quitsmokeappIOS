//
//  UserChartViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/7/14.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import Charts

class UserChartViewController: UIViewController {
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var userDate = ""
    var myChart = MyChart()
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barChart.layer.borderWidth = 1
        barChart.layer.borderColor = UIColor.black.cgColor
        
        datePicker.addTarget(self, action: #selector(UserChartViewController.datePickerChange), for: .valueChanged)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        userDate = formatter.string(from: Date())
        
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(UserChartViewController.goBack))
        let navItem = UINavigationItem(title: "個人圖表")
        navItem.leftBarButtonItem = lefbutton
        navBar.setItems([navItem], animated: false)
        // Do any additional setup after loading the view.
    }
    
    @objc func goBack(){
//        let mainBoard = UIStoryboard(name: "Main", bundle: nil)
//        var VC : UIViewController? =  nil
//
//        VC = mainBoard.instantiateViewController(withIdentifier: "MainViewController")
//
//        self.present(VC!, animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func datePickerChange(datePicker :UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        userDate = formatter.string(from: datePicker.date)
    }
    
    @IBAction func hourSearch(_ sender: Any) {
        myChart.setDate(date: userDate)
        myChart.setLocalData(day: 0)
        myChart.show(view: barChart)
    }
    
    @IBAction func weekSearch(_ sender: Any) {
        myChart.setDate(date: userDate)
        myChart.setLocalData(day: 6)
        myChart.show(view: barChart)
    }
    
    @IBAction func monthSearch(_ sender: Any) {
        myChart.setDate(date: userDate)
        myChart.setLocalData(day: 34)
        myChart.show(view: barChart)
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
