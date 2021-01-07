//
//  ButtonTabViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/5/21.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit

class ButtonTabViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var buttonCollection: UICollectionView!
    
    var imageName = ["presonInfo","friend_icon","barchar","alarmclock","tips","QandA","quiz","about","hospital"]
    var titleArray = ["個人資料","好友","圖表","定時提醒","小常識","醫師問與答","評分表","關於我們","戒菸門診"]
    var tempName : [String] = []
    var tempTitle : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonCollection.dataSource = self
        buttonCollection.delegate = self
        self.buttonCollection.register(UINib(nibName: "ButtonCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "btnCollectCell")
        let mydb = MySQLite.sharedInstance
        
        let userType = mydb?.get_app_data(key: KeyName().SQL_USER_TYPE)
        
        for i in 0...imageName.count-1 {
            if(userType != "0" && (i == 2 || i == 3 || i == 6 )){
                continue
            }
            tempName.append(imageName[i])
            tempTitle.append(titleArray[i])
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tempName.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ButtonCollectionViewCell = self.buttonCollection.dequeueReusableCell(withReuseIdentifier: "btnCollectCell", for: indexPath) as! ButtonCollectionViewCell
        cell.imgFunbtn.contentMode = UIViewContentMode.center
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        cell.imgFunbtn.clipsToBounds = true
        cell.txtFunBtn.text = tempTitle[indexPath.row]
        
        cell.imgFunbtn.image = reSize(image: UIImage(named: tempName[indexPath.row])!, targetSize: CGSize(width: 100, height: 100))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if tempName[indexPath.row] == imageName[0] {
            //user info
            self.performSegue(withIdentifier: "funToInfo", sender: nil)
        }else if tempName[indexPath.row] == imageName[1]{
            //funToFriend
            self.performSegue(withIdentifier: "funToFriend", sender: nil)
        }else if tempName[indexPath.row] == imageName[2]{
            //barchar
            self.performSegue(withIdentifier: "funToChart", sender: nil)
        }else if tempName[indexPath.row] == imageName[3]{
             //funToAlarm
            self.performSegue(withIdentifier: "funToAlarm", sender: nil)
        }else if tempName[indexPath.row] == imageName[4]{
            //tips
            self.performSegue(withIdentifier: "funToTips", sender: nil)
        }else if tempName[indexPath.row] == imageName[5]{
            //funToQandA
            self.performSegue(withIdentifier: "funToQandA", sender: nil)
        }else if tempName[indexPath.row] == imageName[6]{
            //quiz
            self.performSegue(withIdentifier: "funToQuiz", sender: nil)
        }else if tempName[indexPath.row] == imageName[7]{
            //about
            self.performSegue(withIdentifier: "funToAbout", sender: nil)
        }else if tempName[indexPath.row] == imageName[8]{
            //hospital
            let hospitalAlert = UIAlertController(title: "提示", message: "即將打開戒菸門診", preferredStyle: .alert)
            let open = UIAlertAction(title: "打開", style: .default) { (action) in
                UIApplication.shared.open(URL(string: "http://120.96.63.55/quit/website.php")!, options: [:], completionHandler: nil)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            hospitalAlert.addAction(open)
            hospitalAlert.addAction(cancel)
            self.present(hospitalAlert, animated: true, completion: nil)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let padding: CGFloat =  30
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/2, height:  collectionViewSize/2)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //重新縮放
    func reSize(image : UIImage,targetSize : CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
