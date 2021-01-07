//
//  KeyName.swift
//  testphp
//
//  Created by OITMIR on 2018/5/30.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation

struct KeyName {
    //SQL Key name
    let   SQL_USER_ACCOUNT : String = "_account";
    //User info Key
    let   SQL_USER_NAME : String = "_name";
    let   SQL_USER_TYPE : String = "_type";
    let   SQL_SCORE : String = "_smoking_score";
    let   SQL_USER_GENDER : String = "_sex";
    let   SQL_USER_YEARS : String = "_years";
    let   SQL_USER_EMAIL : String = "_email";
    let   SQL_USER_PACKAGE : String = "_package";
    let   SQL_USER_PCS : String = "_pcs";
    let   SQL_USER_SMOKE_YEAR : String = "_smoke_years";
    let   SQL_USER_QUITED : String = "_quited";
    let   SQL_USER_WEIGHT : String = "_weight";
    let   SQL_LAST_MESSAGE : String = "_last_message_id";
    let   SQL_LAST_ALARM : String = "_last_alarm_id";
    let   SQL_LAST_MESSAGE_TIME : String = "_last_message_time";
    let  SQL_USER_INFO : [String] = ["_type","_name", "_sex", "_years", "_email", "_package", "_pcs",
                                     "_smoke_years", "_smoking_score", "_quited", "_weight","_package_money","_sex","_job","_type"];
    let   SQL_PACKAGE_MONEY : String = "_package_money";
    let   SQL_ACCOUNT_STATUS : String = "_account_status";
    //Sync data Key
    let   SQL_SYNC_USER  : String = "_sync_user";
    let   SQL_SYNC_FRIEND : String = "_sync_friend";
    let   SQL_SYNC_SMOKE : String = "_sync_smoke";
    let   SQL_SYNC_SMOKE_TIME : String = "_sync_smoke_time";
    let   SQL_FRIEND_REQUEST : String = "_friend_request";
    let   SQL_NEW_MESSAGE : String = "_new_message";
    
    //Share Key name
    let   SHARE_DO_QUIZ : String = "_do_quiz";
    let   SHARE_FCM_TOKEN : String = "_fcm_token";
    let   SHARE_ACCOUNT : String = "_account";
    let   SHARE_FCM_RE : String = "_fcm_refresh";
    let   SHARE_TOKEN_DATE : String = "_token_date";
    let   SHARE_PASSWORD : String = "_password";
    let   SHARE_LOGIN_COUNT : String = "_login_count";
    let   SHARE_REMIND_ASK : String = "_remind_ask";
    let   SHARE_INI : String = "_data_ini";
    let   SHARE_REMEMBER : String = "_remember_pw";
    let   SHARE_NEW_Profile : String = "_new_profile";
    let   SHARE_NEW_VERSION : String = "_NEW_VERSION";
    let   SHARE_LOGING_OLD : String = "_login_old";
    
    let   APP_VERSION : String = "1.0.6";
    let   RELEASE_TIME : String = "release_time";
    let   RELEASE_NOTE : String = "release_note";
    let   CURRENT_VERSION : String = "1.0.6"
    
    let ALARM_FROM : String = "timeFrom"
    let ALARM_TO : String = "timeTo"
}
