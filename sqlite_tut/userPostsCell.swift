//
//  userPostsCell.swift
//  sqlite_tut
//
//  Created by Developer88 on 3/21/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit

class userPostsCell: UITableViewCell {

    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var bodyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
