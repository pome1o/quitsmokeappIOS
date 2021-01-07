//
//  TipsViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/29.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit

class TipsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tipsTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    let Quest = ["Q：吸菸有助於放鬆心情嗎？","Q：菸癮來了受不了，每次戒菸都失敗，如何戒得了呢？","Q：戒菸會發胖，影響身材？","Q：戒菸會不會害我反應遲鈍、無法思考、脾氣暴躁？","Q：吸菸真的會陽痿嗎？","Q：戒菸小秘訣","Q：目前戒菸藥物有哪些呢？","Q：戒菸有沒有快速有效的方法呢？","Q：有人嘗試過中醫的戒菸針灸嗎？有效還是沒效呢？","Q：我要怎麼開始戒菸呢？","Q：懷孕時，如果繼續抽菸會有什麼影響呢？","Q：抽菸可以減肥，所以我都不敢戒菸。","Q：抽菸皮膚會變差嗎？"]
    let answer =  ["\nA：根據醫學研究報告顯示，菸的作用會使人的血壓上升，心跳加快，並不能達到真正「放鬆」的目的。\n","\nA：戒菸確實有難度，每個人對付菸癮的方式也不盡相同，事實上，大部分的人都是戒了好幾次才成功。將之前的經驗，都當作是一種練習。思考這些過程中，對於下一次的戒菸會有更正面的幫助。\n\n","A：一般而言，戒菸讓人恢復了正常的味覺功能，使得食慾增加。同時，戒菸也使得身體的新陳代謝率恢復，而使得營養吸收比抽菸的時候要好。另一個原因是因為戒菸者一時不習慣手上及嘴巴裡突然少了什麼，而容易吃零食。若能注意這些變化，以蔬菜、水果代替零食，並在事前做好戒菸計畫，將有助於體重的維持。\n",
                   
                   "\nA：戒菸會讓人脾氣變得暴躁，那是因為欲求沒有獲得滿足，而使人覺得較為情緒化。但是，透過一個規畫好的戒菸計畫，例如規律的運動，將可以幫助你調適因為戒菸而產生的情緒起伏。",
                   "\nA：抽菸與勃起障礙有直接和間接的關係，菸中的尼古丁會促使血管收縮、動脈硬化(動脈粥狀硬化)，即使是尼古丁含量低的菸品也是如此。而目前也有研究證實，吸菸者比起非吸菸者，的確有機率較高的勃起障礙問題。\n",
                   
                   "A：\n1.儘量避免辛辣及刺激性的食物。\n2.餐後選用新鮮果汁或含有薄荷的飲料。\n3.餐後刷牙，使口腔維持新鮮乾淨的口感。\n4.避免飲用咖啡或濃茶。\n5.如有抽菸的衝動時，可作深呼吸動作或多喝開水，或作淋浴、散步及運動，或作家務事。\n6.不要使自己有饑餓、憤怒、寂寞及勞累的狀況發生。\n",
                   
                   "\nA：目前國內戒菸藥物有尼古丁替代療法藥物，包括貼片、口嚼錠、口含錠、吸入劑等，此類藥物作用在於補充少量尼古丁，減輕對尼古丁的渴望，以及減緩戒菸時產生的戒斷症狀，不需要醫師處方籤，一般藥局皆可購買。","\nA：電子菸不是替代性療法之一，世衛組織或美國FDA尚未認可其療效，甚至連它是否可以有效協助戒斷，都尚未確認。\n","\nA：根據醫師的說法以及研究指出，從耳朵穴道扎針，可以改變抽菸的味道，讓菸變得不好聞，進而降低想要抽菸的慾望。曾有研究指出個人平均要戒菸三到五次才會成功，姑且不論確切的次數為何，但可以知道的是戒菸是需要一段時間進行的歷程。","\nA：戒菸前，首先可以花個幾天的時間，仔細觀察自己吸菸的行為習慣，了解哪些情況下自己容易抽菸，以及當時想吸菸的念頭有哪些，如果能夠記錄下每一根菸的時間、地點和在什麼情況下抽菸，比較能夠歸類出自己容易控制不抽的時候和覺得困難的地方，再一一針對困難的地方找出解決方式去因應。\n",
                   "\nA：根據WHO世界衛生組織的報告，妊娠中的母親，吸菸比不吸菸者，其所生之胎兒的體重要輕多的。還有使胎兒的成長率明顯的低下。早產和流產的可能性將大大的提高，特別是以前曾經有過死產、流產的孕婦，在懷孕期間切記絕不可吸菸。\n","\nA：抽菸減肥不是個促進健康的好方法，因為，抽菸會阻礙人體正常的代謝功能，而使吸菸者的體重出現病態性的下降。而如果減肥是為了身材好看，也得了解：抽菸同時會阻礙末梢血管運輸養分功能，而使得人體皮膚快速老化，增加皺紋。\n\n","\nA：吸菸會馬上帶入許多毒素進入體內，造成體內的氧化壓力，又容易消耗體內的抗氧化物如維他命C，造成皮膚粗糙、快速老化。容易得心血管疾病與癌症，多和長期的氧化壓力有關。\n\n"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tipsTable.delegate = self
        tipsTable.dataSource = self
        
        let lefbutton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(TipsViewController.goBack))
        let navItem = UINavigationItem(title: "小常識")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Quest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tipsTable.dequeueReusableCell(withIdentifier: "tipsCell", for: indexPath)
        cell.textLabel?.text = Quest[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertView = UIAlertController(title: "解答", message: answer[indexPath.row], preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
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
