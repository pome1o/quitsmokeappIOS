//
//  SqliteDataBase.swift
//  testphp
//
//  Created by oitmis804-12 on 2018/4/19.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation
import SQLite
import SwiftyJSON

class MySQLite  {
    static let sharedInstance = MySQLite()
    
    

    var db : OpaquePointer? = nil
    let dbname = "smokedb.db"
    let dbversion = 1
    let  TABLE_APP_DATA = "tb_app_data";
    let  TABLE_MESSAGE = "tb_message";
    let  TABLE_SMOKE_DATE = "tb_smoke_date";
    let  TABLE_SMOKE_DAY = "tb_smoke_day";
    let TABLE_FRIEND = "tb_friend"
    
    //Common column name
    let  KEY_ID = "_id";
    let  KEY_TIME = "_time";
    let  KEY_DATE = "_date";
    let  KEY_ACCOUNT = "_account";
    
    
    //FRIEND column name
    let  KEY_FRIEND_ID = "_friend_id";
    let  KEY_FRIEND_NAME = "_friend_name";
    let  KEY_FRIEND_NEW_MESSAGE = "_new_message";
    let  KEY_FRIEND_TYPE = "_type";
    
    //App data column name
    let  KEY_DATA_NAME = "_name";
    let  KEY_DATA_VALUE = "_value";
    
    //Message column name
    let  KEY_MSG_TYPE = "_type";
    let  KEY_MSG_REPLY = "_reply";
    let  KEY_MSG_FILE_NAME = "_file_name";
    let  KEY_MSG_MSG = "_message";
    let  KEY_MSG_TITLE = "_title";
    let  KEY_MSG_FROM = "_from_who";
    let  KEY_MSG_TO = "_to_who";
    let  KEY_MSG_IS_DOWNLOAD = "_is_download";
    
    //Smoke date column name
    let  KEY_SMOKE_CN = "_connect";
    let  KEY_DAY = "_day";
    let  KEY_PCS = "_pcs";
    
    private init?(){
        
    }
    
    func iniDB() {
        print("DB Init **********")
        self.db = openDB()
        
        let userDefaults : UserDefaults = UserDefaults.standard
        
        if  (userDefaults.integer(forKey: "dbversion") != 0) {
            var baseVersion = userDefaults.integer(forKey: "dbversion") 
            
            if (db != nil && baseVersion == 0) {
                if(baseVersion == 0){
                    //first time user database
                    createAllTable()
                    userDefaults.set(dbversion, forKey: "dbversion")
                }
                
                if(baseVersion < dbversion){
                    //do update or create new table
                    userDefaults.set(dbversion, forKey: "dbversion")
                }
            }
        }
    }
    
    
    func openDB () -> OpaquePointer {
        print("DB Open **********")
        var db : OpaquePointer? = nil
        let uri = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = uri[uri.count-1].absoluteString + "\(self.dbname)"
        sqlite3_open(path, &db)
        sqlite3_threadsafe()
        return db!
    }
    
    func closeDB(){
        sqlite3_close_v2(db)
    }
    
    func createTable(name:String,columnName :[String]){
        let sql = "create table if not exists \(name)(\(columnName.joined(separator: ",")))" as String
        sqlite3_exec(db, sql, nil, nil, nil)
    }
    
    func createAllTable(){
        createTable(name: self.TABLE_FRIEND , columnName: ["\(KEY_FRIEND_ID) varchar(20) PRIMARY KEY",
            "\(KEY_FRIEND_NAME) varchar(20)",
            "\(KEY_FRIEND_NEW_MESSAGE) INTEGER(1) DEFAULT 0",
            "\(KEY_FRIEND_TYPE) INTEGER(1) DEFAULT 0"])
        
        createTable(name: TABLE_APP_DATA, columnName: ["\(KEY_DATA_NAME) varchar PRIMARY KEY",
            "\(KEY_DATA_VALUE) varchar null"])
        
        createTable(name: TABLE_MESSAGE, columnName: ["\(KEY_ID)  INTEGER PRIMARY KEY",
            "\(KEY_MSG_REPLY) INTEGER",
            "\(KEY_MSG_TYPE) varchar(10) null",
            "\(KEY_MSG_FILE_NAME) varchar(50) null",
            "\(KEY_MSG_MSG) TEXT null",
            "\(KEY_MSG_FROM) varchar(20) null",
            "\(KEY_MSG_TO) varchar(20) null",
            "\(KEY_MSG_TITLE) varchar(20) null",
            "\(KEY_TIME) DATETIME(1) null",
            "\(KEY_MSG_IS_DOWNLOAD) INTEGER(2)"])
        
        createTable(name: TABLE_SMOKE_DATE, columnName: ["\(KEY_ID) INTEGER PRIMARY KEY AUTOINCREMENT",
            "\(KEY_ACCOUNT) VARCHAR (20)",
            "\(KEY_DATE) DATE DEFAULT CURRENT_TIMESTAMP",
            "\(KEY_TIME) TIME DEFAULT CURRENT_TIMESTAMP",
            "\(KEY_SMOKE_CN) INTEGER NOT NULL"])
        
        createTable(name:TABLE_SMOKE_DAY, columnName: ["\(KEY_ACCOUNT) VARCHAR (20)",
            "\(KEY_DAY) String(20)",
            "\(KEY_PCS) int(4)",
            " constraint pk_t2 primary key (\(KEY_ACCOUNT),\(KEY_DAY))"])
        
        let insert_request = "INSERT OR IGNORE INTO \((TABLE_APP_DATA) as String)  (\((KEY_DATA_NAME) as String),\((KEY_DATA_VALUE) as String)) VALUES ('follow_request','0')"
        
        let insert_default_message = "INSERT INTO \((TABLE_MESSAGE) as String) (\(KEY_ID) , \(KEY_MSG_REPLY) , \((KEY_MSG_TYPE) as String) ,\((KEY_MSG_FILE_NAME) as String) , \((KEY_MSG_MSG) as String) ,\((KEY_MSG_FROM) as String) ,\((KEY_MSG_TITLE) as String),\(KEY_MSG_IS_DOWNLOAD)) VALUES ('1','0','text','','記得不要抽菸喔!!!','admin','小幫手^_^','1')"
        var statment : OpaquePointer? = nil
        sqlite3_prepare_v2(db, insert_request, -1, &statment, nil)
        sqlite3_step(statment)
        sqlite3_prepare_v2(db,insert_default_message, -1, &statment, nil)
        sqlite3_step(statment)
        sqlite3_finalize(statment)
    }
    
    /* func <#name#>(<#parameters#>)  {
     var statment  : OpaquePointer? = nil
     var sql = "SELECT * FROM \(TABLE_FRIEND) WHERE  \(KEY_FRIEND_TYPE)  > -1 " as String
     sqlite3_prepare_v2(db, sql, -1, &statment, nil)
     while sqlite3_step(statment) == SQLITE_OK{
     
     }
     return
     } */
    
    func get_friend_data_is_friend() -> [FriendStruct] {
        let sql = "SELECT * FROM \(TABLE_FRIEND)  WHERE  \(KEY_FRIEND_TYPE)   > -1" as String
        return friendQuery(sql: sql)
    }
    
    func get_all_friend_list() -> [FriendStruct] {
        let sql = "Select * From \(TABLE_FRIEND)"
        return friendQuery(sql: sql)
    }
    
    func get_friend_by_order() -> [FriendStruct] {
        let sql = "SELECT * FROM \(TABLE_FRIEND)  WHERE \(KEY_FRIEND_TYPE)  = 0 OR \(KEY_FRIEND_TYPE) = 2 ORDER BY  \(KEY_FRIEND_TYPE)  DESC ,  \(KEY_FRIEND_NEW_MESSAGE) DESC" as String
        return friendQuery(sql: sql)
    }
    
    func get_fritend_name(account :String) -> String{
        let sql = "SELECT \(KEY_FRIEND_NAME) FROM \(TABLE_FRIEND) WHERE \(KEY_FRIEND_ID) = \(account)"
        var statment : OpaquePointer? = nil
        sqlite3_prepare(db, sql, -1, &statment, nil)
        if sqlite3_step(statment) == SQLITE_ROW {
            return checkDataNull(statment: statment!, posititon: 0)!
        }
        return ""
    }
    
    func get_sponsor_data() -> [FriendStruct] {
        let sql = "SELECT * FROM \(TABLE_FRIEND) WHERE \(KEY_FRIEND_TYPE) = 2" as String
        return friendQuery(sql: sql)
    }
    
    func get_message_by_order(account : String) -> [MessageStruct] {
        let sql = "SELECT * FROM  \(TABLE_MESSAGE)  WHERE ( \(KEY_MSG_FROM)  = '\(account)' OR \(KEY_MSG_TO) = '\(account)') AND \(KEY_MSG_REPLY)  = '0' ORDER BY \(KEY_TIME)  DESC"
        return messageQuery(sql:sql)
    }
    
    func get_random_message(hostAccount : String) -> [MessageStruct] {
        let sql = "SELECT * FROM \(TABLE_MESSAGE) WHERE \(KEY_MSG_FROM) != '\(hostAccount)' AND \(KEY_MSG_FROM) != 'Admin' AND \(KEY_MSG_REPLY) = '0'"
        return messageQuery(sql: sql)
    }
    
    func get_one_person_message(account : String) ->[MessageStruct]{
        let sql = "SELECT * FROM \(TABLE_MESSAGE) WHERE \(KEY_MSG_FROM) = \(account)"
        return messageQuery(sql:sql)
    }
    
    func get_reply_message(topicId : Int) ->[MessageStruct]{
        let sql = "SELECT * FROM \(TABLE_MESSAGE) WHERE \(KEY_MSG_REPLY) =\(topicId)"
        return messageQuery(sql: sql)
    }
    
    func get_smoke_date() -> String{
        var statment : OpaquePointer? = nil
        let sql = "SELECT \(KEY_DATE) , \(KEY_TIME)  FROM \(TABLE_SMOKE_DATE) order by  \(KEY_ID)  desc limit 1 " as String
        var date = ""
        sqlite3_prepare(db,sql , -1, &statment, nil)
        if sqlite3_data_count(statment) > 0 {
            while sqlite3_step(statment) == SQLITE_OK{
                date = String(cString : sqlite3_column_text(statment, 0)) + " " + String( cString : sqlite3_column_text(statment, 1))
            }
        }
        sqlite3_finalize(statment)
        return date
    }
    
    func getData(tabel : String) -> OpaquePointer {
        var statment : OpaquePointer? = nil
        let sql = "select * from \(tabel)" as String
        sqlite3_prepare(db,sql, -1, &statment, nil)
        return statment!
    }
    
    func add_app_data(title : String , value : String){
        var statment : OpaquePointer? = nil
        let sql = "replace into \(TABLE_APP_DATA) (\(KEY_DATA_NAME), \(KEY_DATA_VALUE)) VALUES ('\(title)','\(value)')" as String
        
        sqlite3_prepare_v2(db, sql , -1, &statment, nil)
        sqlite3_step(statment)
        sqlite3_finalize(statment)
    }
    
    func update_smoke_day(account : String, time : String){
        let sql = "SELECT * From \(TABLE_SMOKE_DATE) WHERE _date LIKE '%\(time)%' and _account = '\(account)'"
        let smokeDate = smokeDateQuery(sql: sql)
        if smokeDate.count > 0 {
            let sql_update = "INSERT OR REPLACE INTO \(TABLE_SMOKE_DAY) (_account,_day,_pcs) VALUES ('\(account)','\(time)',(SELECT CASE WHEN exists(SELECT 1 FROM \(TABLE_SMOKE_DAY) WHERE _day ='\(time)') THEN \(smokeDate.count) ELSE \(smokeDate.count) END ))"
            var statment  : OpaquePointer? = nil
            sqlite3_prepare(db, sql_update, -1, &statment, nil)
            sqlite3_step(statment)
            sqlite3_finalize(statment)
        }
        
    }
    
    func load_smoke_data(account :String, date : JSON, time : JSON){
        var statment : OpaquePointer? = nil
        for i in 0...date.count {
            let sql = "INSERT OR REPLACE INTO tb_smoke_date(_account,_date,_time,_connect) VALUES ('\(account)','\(date[i])',(SELECT CASE WHEN exists(SELECT 1 FROM \(TABLE_SMOKE_DATE) WHERE _date = '\(date[i])') THEN ' \(time[i])' ELSE '\(time[i])' END),'1')"
            sqlite3_prepare(db, sql, -1, &statment, nil)
            sqlite3_step(statment)
            sqlite3_finalize(statment)
        }
    }
    
    func get_app_data(key : String) -> String {
        var statment : OpaquePointer? = nil
        let sql = "select * from \(TABLE_APP_DATA) WHERE \(KEY_DATA_NAME) = '\(key)'" as String
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        if sqlite3_column_count(statment) > 0 {
            sqlite3_step(statment)
            return checkDataNull(statment: statment!, posititon: 1)!
        }
        return ""
    }
    
    func add_friend(friend_id : String,friend_name : String,type : String){
        var statment : OpaquePointer? = nil
        let sql = "INSERT OR REPLACE INTO \(TABLE_FRIEND)  (\(KEY_FRIEND_ID) ,\(KEY_FRIEND_NAME),\(KEY_FRIEND_TYPE)) VALUES ('\(friend_id)','\(friend_name)','\(type)') "
        sqlite3_prepare_v2(db, sql , -1, &statment, nil)
        sqlite3_step(statment)
        sqlite3_finalize(statment)
    }
    
    func update_friend(friend_id : String , i : Int){
        var statment : OpaquePointer? = nil
        let sql = "select * frome \(TABLE_FRIEND) WHERE \(KEY_FRIEND_ID) = '\(friend_id)'" as String
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        if sqlite3_data_count(statment) > 0 {
            var statment2 : OpaquePointer? = nil
            let update = "UPDATE \(TABLE_FRIEND) SET \(KEY_FRIEND_NEW_MESSAGE) = \(i) WHERE \(KEY_FRIEND_ID) = '\(KEY_FRIEND_ID)'"
            sqlite3_prepare_v2(db, update, -1, &statment2, nil)
            sqlite3_step(statment2)
            sqlite3_finalize(statment2)
        }
        sqlite3_finalize(statment)
    }
    
    func del_friend(friend_id : String) -> Bool {
        var statment : OpaquePointer? = nil
        let sql = "DELETE FROM \(TABLE_FRIEND) WHERE \(KEY_FRIEND_ID) = '\(friend_id)'"
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        if sqlite3_step(statment) == SQLITE_OK {
            return true
        }
        return false
    }
    
    func delet_item(account : String){
        var statment : OpaquePointer? = nil
        let sql = "DELETE FROM \(TABLE_MESSAGE) WHERE _from_who ='\(account)' or _to_who ='\(account)'" as String
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        sqlite3_step(statment)
    }
    
    func add_message(id : String, reply_id : String, msg : String, type : String, path : String, title : String, frome_who : String, to_who : String, timestamp : String, isdownload : Int) {
        
        var statment : OpaquePointer? = nil
        let sql = "INSERT INTO \(TABLE_MESSAGE) (\(KEY_ID),\(KEY_MSG_REPLY),\(KEY_MSG_TYPE),\(KEY_MSG_FILE_NAME),\(KEY_MSG_MSG),\(KEY_MSG_FROM),\(KEY_MSG_TO),\(KEY_MSG_TITLE),\(KEY_TIME),\(KEY_MSG_IS_DOWNLOAD)) VALUES ('\(id)','\(reply_id)','\(type)','\(path)','\(msg)','\(frome_who)','\(to_who)','\(title)','\(timestamp)','\(isdownload)')" as String
        sqlite3_prepare_v2(db, sql , -1, &statment, nil)
        sqlite3_step(statment)
        sqlite3_finalize(statment)
    }
    
    func lastTime(type : Int , account : String) -> [MessageStruct]{
        var sql = ""
        if type == 1{
            sql = "SELECT * FROM \(TABLE_MESSAGE)  WHERE \(KEY_MSG_REPLY) = 0 AND \(KEY_MSG_FROM)  !=  \(account) ORDER BY \(KEY_TIME)  DESC LIMIT 1"
        }else {
            sql = "SELECT * FROM \(TABLE_MESSAGE) ORDER BY  \(KEY_TIME)  DESC LIMIT 1"
        }
        return messageQuery(sql: sql)
    }
    
    func add_smoke_record(account : String, date : String , time : String , count : Int) {
        var statment : OpaquePointer? = nil
        if count > 0 {
            for _ in 0...count-1{
                let sql = "INSERT INTO \(TABLE_SMOKE_DATE) (\(KEY_ACCOUNT),\(KEY_DATE),\(KEY_TIME),\(KEY_SMOKE_CN)) VALUES ('\(account)','\(date)','\(time)','\(0)')"
                sqlite3_prepare_v2(db, sql, -1, &statment, nil)
                sqlite3_step(statment)
                
            }
            sqlite3_finalize(statment)
        }
    }
    
    func smoke_no_sync_data() -> [SmokeStruct.Day] {
        let sql = "select * from \(TABLE_SMOKE_DATE)  where _connect = 0"
        return smokeDayQuery(sql: sql)
    }
    
    func update_smoke_sync_type(){
        var statment : OpaquePointer? = nil
        let sql = "UPDATE \(TABLE_SMOKE_DATE)  SET _connect = 1 "
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        sqlite3_step(statment)
    }
    
    func del_all(tableName : String){
        let sql = "DELETE \(tableName)"
        var statment : OpaquePointer? = nil
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        sqlite3_step(statment)
        sqlite3_finalize(statment)
    }
    
    func fetchSmokeToday(account : String , date : String) -> [Double] {
        var dataArray : [Double] = []
        var statment : OpaquePointer? = nil
        
        for i in 0...23{
        
            let sql = "SELECT *,COUNT(_time) FROM \(TABLE_SMOKE_DATE) WHERE _time >= '\(String(i)):00:00' and _time <=('\(String(i)):59:59') and _account = '\(account)' and _date = '\(date)' "
            sqlite3_prepare(db, sql, -1, &statment, nil)
            if sqlite3_step(statment) == SQLITE_ROW {
                dataArray.append(Double(sqlite3_column_int(statment, 5)))
            }else{
                dataArray.append(0.0)
            }
        }
        sqlite3_finalize(statment)
        return dataArray
    }
    
    func fetchSmokeByInterval(account : String , date : String , howManyDay : Int,userDate : String) -> [Double] {
        var dataArray : [Double] = []
        var statment : OpaquePointer? = nil
        
        for i in (0...howManyDay).reversed() {
            let sql = "SELECT COUNT(_date) FROM \(TABLE_SMOKE_DATE) WHERE _date = date('\(date)','-\(i) days') and _account = '\(account)'"
            
            sqlite3_prepare(db, sql,-1, &statment, nil)
            
            if sqlite3_step(statment) == SQLITE_ROW {
            
                dataArray.append(Double(sqlite3_column_int(statment, 0)))
            }else{
                dataArray.append(0.0)
            }
        }
        sqlite3_finalize(statment)
        return dataArray
    }
    
    func fetchSmokeUpdate() -> OpaquePointer{
        let sql = "select * from \(TABLE_SMOKE_DATE) WHERE _connect = 0"
        var statment : OpaquePointer? = nil
        sqlite3_prepare(db, sql, -1, &statment, nil)
        return statment!
    }
    
    
    func testData(){
        let sql = "SELECT * FROM  \(TABLE_SMOKE_DATE) "
        var statment : OpaquePointer? = nil
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        
        while sqlite3_step(statment) == SQLITE_ROW {
     
            print( String(cString: sqlite3_column_text(statment, 2)))
            print( String(cString: sqlite3_column_text(statment, 3)))
        }
    }
    
    
    //下面負責將資料處理後使用struct回傳
    
    private func smokeDateQuery(sql :String) -> [SmokeStruct.Date] {
        var temp_array : [SmokeStruct.Date] = []
        var statment : OpaquePointer? = nil
        sqlite3_prepare_v2(db, sql, -1, &statment, nil)
        while sqlite3_step(statment) == SQLITE_ROW {
            sqlite3_column_count(statment)
            temp_array.append(SmokeStruct.Date(
                account: checkDataNull(statment: statment!, posititon: 0)!,
                dateTime: checkDataNull(statment: statment!, posititon: 1)!,
                time: checkDataNull(statment: statment!, posititon: 2)!,
                isSync: Int(sqlite3_column_int(statment, 3)),
                dateCount: Double(sqlite3_column_int(statment, 4))
            ))
        }
        return temp_array
    }
    
    private func smokeDayQuery(sql: String) -> [SmokeStruct.Day] {
        var temp_array : [SmokeStruct.Day] = []
        var statment : OpaquePointer? = nil
        sqlite3_prepare(db, sql, -1, &statment, nil)
        while sqlite3_step(statment) == SQLITE_ROW {
            temp_array.append(SmokeStruct.Day(account:checkDataNull(statment: statment!, posititon: 0),
                                              day: checkDataNull(statment: statment!, posititon: 1),
                                              pcs: Double(sqlite3_column_int(statment, 2))))
        }
        sqlite3_finalize(statment)
        return temp_array
    }
    
    private func friendQuery(sql : String) -> [FriendStruct] {
        var temp_array : [FriendStruct] = []
        var statment : OpaquePointer? = nil
        sqlite3_prepare(db, sql, -1, &statment, nil)
        while sqlite3_step(statment) == SQLITE_ROW {
            
            temp_array.append(FriendStruct(account: checkDataNull(statment: statment!, posititon: 0),
                                           user_name: checkDataNull(statment: statment!, posititon: 1),
                                           new_message: Int(sqlite3_column_int(statment, 2)),
                                           type: Int(sqlite3_column_int(statment, 3))))
        }
        sqlite3_finalize(statment)
        return temp_array
    }
    
    private func messageQuery(sql : String) -> [MessageStruct] {
        var statment : OpaquePointer? = nil
        var temp_array : [MessageStruct] = []
        sqlite3_prepare(db, sql, -1, &statment, nil)
        while sqlite3_step(statment) == SQLITE_ROW {
            temp_array.append(MessageStruct(_id: Int(sqlite3_column_int(statment, 0)),
                                            reply: Int(sqlite3_column_int(statment, 1)),
                                            msg_type: checkDataNull(statment: statment!, posititon: 2),
                                            file_name: checkDataNull(statment: statment!, posititon: 3),
                                            message: checkDataNull(statment: statment!, posititon: 4),
                                            from: checkDataNull(statment: statment!, posititon: 5),
                                            to: checkDataNull(statment: statment!, posititon: 6),
                                            title: checkDataNull(statment: statment!, posititon: 7),
                                            datetime:checkDataNull(statment: statment!, posititon: 8),
                                            is_download: Int(sqlite3_column_int(statment, 9))))
        }
        sqlite3_finalize(statment)
        return temp_array
    }
    
    private func checkDataNull(statment : OpaquePointer, posititon : Int) -> String? {
        
        return sqlite3_column_text(statment, Int32(posititon)) == nil ? "" : String(cString: sqlite3_column_text(statment, Int32(posititon)))
    }
    
}
