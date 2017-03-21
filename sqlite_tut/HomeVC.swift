//
//  HomeVC.swift
//  sqlite_tut
//
//  Created by Devloper30 on 21/03/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit

class HomeVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblStudentData: UITableView!
    var marrStudentData: NSMutableArray! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tblStudentData.delegate = self
        tblStudentData.dataSource = self
        tblStudentData.register(UINib(nibName: "StudentCell", bundle: nil), forCellReuseIdentifier: "StudentCell")
        tblStudentData.allowsSelection = false
    }
    override func viewWillAppear(_ animated: Bool) {
        getStudentData()
    }
    
    @IBAction func handleBtnInsert(_ sender: Any) {
        self.navigationController?.pushViewController(InsertRecordVC(), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marrStudentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
//        let student:AnyObject = marrStudentData.object(at: indexPath.row) as! AnyObject
//        cell.lblName.text = "Name : \(student.Name)"
//        cell.lblId.text = "Marks : \(student.Marks)"
//        cell.student = student
//        cell.main = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func getStudentData()
    {
        marrStudentData = NSMutableArray()
        marrStudentData = ModelManager.getInstance().getAllStudentData()
        tblStudentData.reloadData()
    }

}
