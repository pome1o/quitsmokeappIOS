//
//  QandAViewController.swift
//  testphp
//
//  Created by OITMIR on 2018/6/23.
//  Copyright © 2018 OITMIB. All rights reserved.
//

import UIKit
import WebKit

class QandAViewController: UIViewController,WKNavigationDelegate {

    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://120.96.63.55/quit/qna/mobile/client_mobile.php")
        webView.load(URLRequest(url: url!))
        //http://120.96.63.55/quit/qna/mobile/client_mobile.php
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let back = UIBarButtonItem(barButtonSystemItem: .reply, target: webView, action: #selector(webView.goBack))
        toolbarItems = [back,refresh]
        navigationController?.isToolbarHidden = false
        
        let topButton = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(self.goBack))
        self.navigationItem.leftBarButtonItem = topButton
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    @objc func goBack(){
        self.dismiss(animated: true, completion: nil)
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
