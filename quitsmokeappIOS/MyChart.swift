//
//  MyChart.swift
//  testphp
//
//  Created by OITMIR on 2018/6/9.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import Charts

class MyChart {
    //日期
    private var smokeDate = ""
    //儲存時間
    private var smokeDataByDate : [SmokeStruct.Date] = []
    private var dateFormat : DateFormatter
    private var howManyDay = 0
    private var totalCount = 0
    //儲存根數
    private var friendSmokeCount : [Double] = []
    private var fromNet = false
    
    struct SmokeDay {
        let Week = 6
        let Month = 34
        let Today = 0
    }
    
    
    init() {
        dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = Locale(identifier: "zh_Hant_TW")
        smokeDate = dateFormat.string(from: Date())
        
    }
    
    //設定日期 不輸入 預設為今天
    func setDate(year : Int, month :Int, day : Int){
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        let calendar = Calendar.current
        smokeDate = dateFormat.string(from: calendar.date(from: components)!)
    }
    
    func setDate(date : String){
        self.smokeDate = date
    }
    
    //網路上來的資料
    func setData(data : [Double],day:Int){
        fromNet = true
        self.friendSmokeCount = self.friendSmokeCount + data
        if day <= 0 {
            processToday(smokeCount: friendSmokeCount)
        }else{
            if day >= 34{
                processMonth(smokeCount: friendSmokeCount)
            }else if day == 6 {
                processWeek(smokeCount: friendSmokeCount)
            }
        }
       
    }
    
    //資料庫內資料
    func setLocalData(day : Int){
        self.howManyDay = day
        let mysql = MySQLite.sharedInstance
        let userAccount = UserDefaults.standard.string(forKey: KeyName().SHARE_ACCOUNT)
        if day <= 0 {
            let smokeCount =  (mysql?.fetchSmokeToday(account: userAccount!, date: smokeDate))!
            
            processToday(smokeCount: smokeCount)
        }else{
            let  smokeCount = (mysql?.fetchSmokeByInterval(account: userAccount!, date: smokeDate, howManyDay: self.howManyDay,userDate: smokeDate))!
            
            if day >= 34 {
                processMonth(smokeCount: smokeCount)
            }else if day == 6 {
                processWeek(smokeCount: smokeCount)
            }
        }
    }
    
    //取得Y-value
    func getDataEntry () ->[BarChartDataEntry] {
        var y : [BarChartDataEntry] = []
        for i in 0...smokeDataByDate.count-1 {
            let entry = BarChartDataEntry(x: Double(i), y: smokeDataByDate[i].dateCount)
            y.append(entry)
        }
        
        return y
    }
    
    //取得X-title
    func getXTitle() -> [String] {
        var x : [String] = []
        for i in 0...smokeDataByDate.count-1 {
            x.append(smokeDataByDate[i].dateTime)
        }
        
        return x
    }
    
    func detailText() ->String{
        var totalSmoke = 0
        for i in 0...smokeDataByDate.count {
            totalSmoke = totalSmoke + Int(smokeDataByDate[i].dateCount)
        }
        let detail = "總共抽了\(totalSmoke)支"
        return detail
    }
    
    //將所有變數設定到barchar 上
    func show(view : BarChartView){
        let chartDataSet = BarChartDataSet(values: self.getDataEntry(), label: "支")
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.valueFont =  UIFont.systemFont(ofSize: 12)
        let chartData = BarChartData(dataSet: chartDataSet)
        view.data = chartData
        view.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.getXTitle())
        view.xAxis.granularity = 1
    }
    
    private func processToday(smokeCount : [Double]){
        smokeDataByDate = []
        var test = 0
        var posistionCount = 0
        for i in stride(from: 0, to: 24, by: 2) {
            var sum = 0.0
            if(posistionCount < 23){
                for _ in 0...2 {
                    sum += smokeCount[posistionCount]
                    posistionCount += 1
                }
            }
            test += 1
            smokeDataByDate.append(
                SmokeStruct.Date(account: "", dateTime: "\(i)~\(i+2)", time: "", isSync: 0, dateCount: sum))
        }
    }
    
    private func processWeek(smokeCount : [Double]){
        smokeDataByDate = []
        let calendar = Calendar.current
        let formate = DateFormatter()
        formate.dateFormat = "MM/dd"
        var date = calendar.startOfDay(for: dateFormat.date(from: smokeDate)!)
        date = calendar.date(byAdding: .day, value: -6, to: date)!
        for i in 0...smokeCount.count-1 {
            smokeDataByDate.append(SmokeStruct.Date(account: "", dateTime: formate.string(from: date), time: "", isSync: 0, dateCount: smokeCount[i]))
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
    }
    
    private func processMonth(smokeCount :[Double]){
        smokeDataByDate = []
        let calendarFrom = Calendar.current
        let calendarTo = Calendar.current
        let formate = DateFormatter()
        formate.dateFormat = "MM/dd"
        let formateOnly = DateFormatter()
        formateOnly.dateFormat = "dd"
        var dateFrom = calendarFrom.startOfDay(for: dateFormat.date(from: smokeDate)!)
        dateFrom = calendarFrom.date(byAdding: .day, value: -34, to: dateFrom)!
        var dateTo = calendarTo.startOfDay(for: dateFormat.date(from: smokeDate)!)
        dateTo = calendarTo.date(byAdding: .day, value: -34, to: dateTo)!
        
        var fromValue = 0
        
        for i in stride(from: 0, to: 34, by: 7){
            var sum = 0
            for k in 0...7 {
                
                if k+i != 35 {
                    sum = sum + Int(smokeCount[k+i])
                }
            }
            
            if(i > 0){
                fromValue = 8
            }
            dateFrom = calendarFrom.date(byAdding: .day, value: fromValue, to: dateFrom)!
            dateTo = calendarTo.date(byAdding: .day, value: 7, to: dateTo)!
            let date = "\(formate.string(from: dateFrom))~\(formateOnly.string(from: dateTo))"
            
            smokeDataByDate.append(SmokeStruct.Date(account: "", dateTime: date, time: "", isSync: 0, dateCount: Double(sum)))
        }
    }
}
