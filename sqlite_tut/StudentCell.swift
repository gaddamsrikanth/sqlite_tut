//
//  StudentCell.swift
//  sqlite_tut
//
//  Created by Devloper30 on 21/03/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {
    @IBOutlet var lblId: UILabel!
    @IBOutlet var lblName: UILabel!
    
    var student: AnyObject!
    var main: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func handleBtnEdit(_ sender: Any) {
        let vc = InsertRecordVC()
        vc.isEdit = true
        vc.student = student
        main.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func handleBtnDelete(_ sender: Any) {
        (main as! HomeVC).fetchServerData("users/\((student as! User).id! + 1)")
        (sender as! UIButton).isHidden = true
    }
}
