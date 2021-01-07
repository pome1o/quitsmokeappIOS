//
//  EncryptClass.swift
//  testphp
//
//  Created by OITMIR on 2018/5/10.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation
import CryptoSwift

class DataEncrypt {
    
     func encode(data : String) -> String? {
        
        let user_data : [UInt8] = Array(data.utf8)
        var encrypted : [UInt8] = []
        let mykey : [UInt8] = Array("smokingisnotgood1234567quitsmoke".utf8)
        let myiv : [UInt8] = Array("ABCDEF12345678PL".utf8)
        
        do{
            encrypted = try AES(key : mykey ,blockMode : .CBC(iv: myiv), padding: .pkcs5).encrypt(user_data)
        }catch{
            
        }
        let encodedData = Data.init(bytes: encrypted)
        return encodedData.base64EncodedString(options: .lineLength64Characters) + "\n"
    }
}
