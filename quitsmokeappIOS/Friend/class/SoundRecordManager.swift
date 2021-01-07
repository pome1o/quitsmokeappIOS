//
//  SoundRecord.swift
//  testphp
//
//  Created by OITMIR on 2018/6/7.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SoundRecordManager : NSObject {
    
    private var recorder : AVAudioRecorder? = nil
    private var player : AVAudioPlayer? = nil
    private var fileManager : FileManager
    private var dirPath = ""
    private var friendAccount = ""
    private var haveRecordFile = false
    private var recordFilePath = ""
    private var recordSetting : [String : Any] = [:]
    
    init(friendAccount : String){
        fileManager = FileManager.default
        self.friendAccount = friendAccount
        let uri = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        dirPath = (uri?.appendingPathComponent(self.friendAccount).path)!
        recordFilePath = dirPath + "/temp.m4a"
    }
    
    func setupRecord(){
        checkDir(path: self.dirPath)
        let session = AVAudioSession.sharedInstance()
        
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        }catch let erro {
            debugPrint(erro)
        }
        
        do{
            try session.setActive(true)
        } catch let erro {
            debugPrint(erro)
        }
        recordSetting  = [
            AVSampleRateKey : 1600,
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVLinearPCMBitDepthKey : 16,
            AVNumberOfChannelsKey : 1
        ]
    }
    
     func startRecord(){
        do{
            recorder = try AVAudioRecorder(url: URL(string: recordFilePath)!, settings: recordSetting)
            print(recordFilePath)
            recorder?.prepareToRecord()
            recorder?.record()
            haveRecordFile = true
        }catch let error {
            haveRecordFile = false
            debugPrint(error)
        }
    }
    
    func stopRecord(){
        if recorder != nil {
            recorder?.stop()
            recorder = nil
        }
    }
    
    func playSound(){
        do {
            player = try AVAudioPlayer(contentsOf: URL(string: recordFilePath)!)
            player?.play()
        }catch let error {
            debugPrint(error)
        }
    }
    
    func stopPlay(){
        if player != nil {
            player?.stop()
        }
    }
    
    private func checkDir(path :String){
        var isDir : ObjCBool = false
        if !(fileManager.fileExists(atPath: path, isDirectory: &isDir)) && !isDir.boolValue{
            do{
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func copyFile(fileName : String){
        let newPath = dirPath + "/\(fileName)"
        do{
        try fileManager.copyItem(atPath: recordFilePath, toPath: newPath)
        }catch let error {
            debugPrint(error)
        }
    }
    
    func getRecordPath() -> String{
        return self.recordFilePath
    }
    
    func haveRecord() -> Bool {
        return self.haveRecordFile
    }
}
