//
//  CheckConnection.swift
//  testphp
//
//  Created by OITMIR on 2018/6/18.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnected() -> Bool{
        return NetworkReachabilityManager(host: "http://google.com")!.isReachable
    }
}
