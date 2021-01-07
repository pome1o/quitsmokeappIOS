//
//  LoadingAnimation.swift
//  testphp
//
//  Created by OITMIR on 2018/6/7.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class LoadingAnimation {
   private var loadingView : UIView?
   private var activityIndicator : NVActivityIndicatorView?
   private var currentView : UIView
   private var loadingLabel : UILabel?
    
    init(view : UIView) {
        self.currentView = view
    }
    
    
    func prepareView(){
        if activityIndicator == nil || loadingView == nil {
            loadingView = UIView(frame: CGRect(x: 0, y: 400, width: 90, height: 90))
            loadingView?.backgroundColor = UIColor(white: 0, alpha: 0.6)
            loadingView?.layer.cornerRadius = 10
            loadingView?.center = currentView.center
            loadingLabel = UILabel(frame: CGRect(x: 4.5, y: 55, width: 80, height: 30))
            
            loadingLabel?.text = "資料上傳中..."
            loadingLabel?.textColor = .white
            loadingLabel?.font = UIFont(name: (loadingLabel?.font.fontName)!, size: 15)
            loadingLabel?.textAlignment = .center
            loadingView?.addSubview(loadingLabel!)
            
            let frame = CGRect(x: 0, y: 0, width: 45, height: 45)
            activityIndicator = NVActivityIndicatorView(frame: frame)
            activityIndicator?.type = NVActivityIndicatorType.lineSpinFadeLoader
            activityIndicator?.center = CGPoint(x: (loadingView?.frame.size.width)! / 2.0, y: 35)
            activityIndicator?.color = .white
            
            loadingView?.addSubview(activityIndicator!)
            loadingView?.isHidden = true
            currentView.addSubview(loadingView!)
        }
    }
    
    func setText(msg : String){
        loadingLabel?.text = msg
    }
    
    func playAnimating(){
        loadingView?.isHidden = false
        activityIndicator?.startAnimating()
    }
    
    func stopAnimating(){
        loadingView?.isHidden = true
        activityIndicator?.stopAnimating()
    }
    
}
