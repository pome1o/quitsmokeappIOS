//
//  MessageStruct.swift
//  testphp
//
//  Created by OITMIR on 2018/4/26.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation

struct MessageStruct {
    var _id : Int = -1;
    var reply : Int = -1
    var msg_type : String? = nil
    var file_name : String? = nil
    var message : String? = nil
    var from : String? = nil
    let to : String?
    var title : String? = nil
    var datetime : String?
    var is_download : Int = 0
}
