//
//  NewMsgTableViewCell.swift
//  testphp
//
//  Created by OITMIR on 2018/5/28.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit

class NewMsgTableViewCell: UITableViewCell {
   
    @IBOutlet weak var newMsgType: UILabel!
    @IBOutlet weak var newMsgName: UILabel!
    @IBOutlet weak var newMsgTitle: UILabel!
    @IBOutlet weak var newMsgContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
