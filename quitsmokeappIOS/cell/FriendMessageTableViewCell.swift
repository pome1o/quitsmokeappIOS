//
//  FriendMessageTableViewCell.swift
//  testphp
//
//  Created by OITMIR on 2018/6/2.
//  Copyright © 2018年 OITMIB. All rights reserved.
//

import UIKit

class FriendMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbType: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    @IBOutlet weak var lbName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
