//
//  HomeVC.swift
//  sqlite_tut
//
//  Created by Devloper30 on 21/03/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import ObjectMapper

class HomeVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblStudentData: UITableView!
    var mUserData: NSMutableArray! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchServerData("users/1")
        self.navigationController?.isNavigationBarHidden = true
        tblStudentData.delegate = self
        tblStudentData.dataSource = self
//        tblStudentData.register(UINib(nibName: "StudentCell", bundle: nil), forCellReuseIdentifier: "StudentCell")
        tblStudentData.allowsSelection = false
    }
    override func viewWillAppear(_ animated: Bool) {
//        getStudentData()
    }
    
    @IBAction func handleBtnInsert(_ sender: Any) {
        self.navigationController?.pushViewController(InsertRecordVC(), animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mUserData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
//        let student:AnyObject = marrStudentData.object(at: indexPath.row) as! AnyObject
//        cell.lblName.text = "Name : \(student.Name)"
//        cell.lblId.text = "Marks : \(student.Marks)"
//        cell.student = student
//        cell.main = self
        let cell = tableView.dequeueReusableCell(withIdentifier: "")
//        let user: User = mUserData.object(at: indexPath.row) as! User
//        cell.lblName.text = "Name : \(user.name!)"
//        cell.lblId.text = "id : \(user.id!)"
//        cell.student = user
//        cell.main = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func getStudentData()
    {
        mUserData = NSMutableArray()
        //mUserData = ModelManager.getInstance().getAllData()
        tblStudentData.reloadData()
    }
    
    func fetchServerData(_ url: String) {
        server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl:  url, strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            
        }, responseDictionary: { (resultDic) in
            DispatchQueue.main.async {
                let user: User = Mapper<User>().map(JSONObject: resultDic)!
                self.mUserData.add(user)
                self.tblStudentData.reloadData()
            }
        }, responseArray: { (resultArr) in
            
        })
    }

}
