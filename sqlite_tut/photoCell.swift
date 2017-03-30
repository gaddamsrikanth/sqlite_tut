//
//  photoCell.swift
//  sqlite_tut
//
//  Created by devloper65 on 3/22/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit

class photoCell: UITableViewCell {
    @IBOutlet var imgBackPic: UIImageView!
    @IBOutlet var imgProPic: UIImageView!
    @IBOutlet var lbltitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgProPic.image = nil
        self.imgBackPic.image = nil
        self.lbltitle.text = nil
    }
}
