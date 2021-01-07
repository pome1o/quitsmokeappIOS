//
//  QuizViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/29.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    var oneIsSelected = false
    var twoIsSelected = false
    var threeIsSelected = false
    var fourIsSelected = false
    var fiveIsSelected = false
    var sixIsSelected = false
    var scoreArray : [Int] = [0,0,0,0,0,0,0]
    override func viewDidLoad() {
        super.viewDidLoad()
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(QuizViewController.goBack))
        let navItem = UINavigationItem(title: "測驗")
        navItem.leftBarButtonItem = lefbutton
        navBar.setItems([navItem], animated: false)
        
        // Do any additional setup after loading the view.
    }
    
    @objc func goBack(){
        /*let mainBoard = UIStoryboard(name: "Main", bundle: nil)
        var VC : UIViewController? =  nil
        
        VC = mainBoard.instantiateViewController(withIdentifier: "MainViewController")
        
        self.present(VC!, animated: true, completion: nil)*/
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func sumScore(_ sender: Any) {
        var message = ""
        if oneIsSelected && twoIsSelected && threeIsSelected && fourIsSelected && fiveIsSelected && sixIsSelected {
            let sumScore = scoreArray.reduce(0, +)
            
            if sumScore <= 5 {
                message = "成癮程度不高，現在下定決心，一定可以成功"
            }else if sumScore <= 7 {
                message = "依賴程度偏高 \n 亞東醫院戒菸專線：(02)89667000轉4271 \n"
            }else {
                message = "嚴重成癮，請尋求醫師協助 \n 亞東醫院戒菸專線：(02)89667000轉4271 \n"
            }
            let mydb = MySQLite.sharedInstance
            mydb?.add_app_data(title: KeyName().SQL_SCORE, value: String(sumScore))
            UserDefaults.standard.set(1, forKey: KeyName().SHARE_DO_QUIZ)
            
        }else{
            message = "請作答完整"
        }
        
        let alertControll = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        let goHospital = UIAlertAction(title: "亞東醫院網站", style: .default) { (action) in
            UIApplication.shared.open(URL(string: "https://hos.femh.org.tw/newfemh/webregs/RegSec1.aspx?type=sec&id=0292")!, options: [:], completionHandler: nil)
        }
        
        alertControll.addAction(goHospital)
        alertControll.addAction(okAction)
        self.present(alertControll, animated: true, completion: nil)
    }
    
    @IBAction func questionOne(_ sender: UIButton) {
        var oneScore = 0
        for i in 0...3 {
            if sender.tag == i + 100 {
                sender.isSelected = true
                oneIsSelected = true
               
                switch sender.tag {
                case 100:
                  oneScore = 3
                    break
                case 101:
                    oneScore = 2
                    break
                case 102:
                    oneScore = 1
                    break
                case 103:
                    oneScore = 0
                    break
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 100) as! UIButton
            Btn.isSelected = false
        }
        scoreArray[0] = oneScore
    }
    
    @IBAction func questionTwo(_ sender: UIButton) {
        var twoScore = 0
        for i in 0...1 {
            if sender.tag == i + 200 {
                twoIsSelected = true
                sender.isSelected = true
                switch sender.tag {
                case 200:
                    twoScore = 1
                    break
                case 201:
                    twoScore = 0
                    break
               
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 200) as! UIButton
            Btn.isSelected = false
        }
        scoreArray[1] = twoScore
    }
    
    @IBAction func questionThree(_ sender: UIButton) {
        var threeScore = 0
        for i in 0...1 {
            if sender.tag == i + 300 {
                threeIsSelected = true
                sender.isSelected = true
                switch sender.tag {
                case 300:
                    threeScore = 1
                    break
                case 301:
                    threeScore = 0
                    break
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 300) as! UIButton
            Btn.isSelected = false
        }
        scoreArray[2] = threeScore
    }
    
    @IBAction func questionFour(_ sender: UIButton) {
        var fourScore = 0
        for i in 0...3 {
            if sender.tag == i + 400 {
                fourIsSelected = true
                sender.isSelected = true
                switch sender.tag {
                case 400:
                    fourScore = 3
                    break
                case 401:
                     fourScore = 2
                    break
                case 402:
                     fourScore = 1
                    break
                case 403:
                     fourScore = 0
                    break
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 400) as! UIButton
            Btn.isSelected = false
        }
        scoreArray[3] = fourScore
    }
    
    @IBAction func questionFive(_ sender: UIButton) {
        var fiveScore = 0
        for i in 0...1 {
            if sender.tag == i + 500 {
                fiveIsSelected = true
                sender.isSelected = true
                switch sender.tag {
                case 500:
                    fiveScore = 1
                    break
                case 501:
                    fiveScore = 0
                    break
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 500) as! UIButton
            Btn.isSelected = false
        }
        scoreArray[4] = fiveScore
    }
    
    @IBAction func questionSix(_ sender: UIButton) {
        var sixScore = 0
        for i in 0...1 {
            if sender.tag == i + 600 {
                sixIsSelected = true
                sender.isSelected = true
                switch sender.tag {
                case 600:
                    sixScore = 1
                    break
                case 601:
                    sixScore = 0
                    break
                default:
                    break
                }
                continue
            }
            let Btn:UIButton = self.view.viewWithTag(i + 600) as! UIButton
            Btn.isSelected = false
        }
        scoreArray[5] = sixScore
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
