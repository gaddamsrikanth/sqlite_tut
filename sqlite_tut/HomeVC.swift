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
//        fetchServerData("users/1")
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
        return mUserData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath) as! StudentCell
//        let student:AnyObject = marrStudentData.object(at: indexPath.row) as! AnyObject
//        cell.lblName.text = "Name : \(student.Name)"
//        cell.lblId.text = "Marks : \(student.Marks)"
//        cell.student = student
//        cell.main = self
        let user: User = mUserData.object(at: indexPath.row) as! User
        cell.lblName.text = "Name : \(user.name!)"
        cell.lblId.text = "id : \(user.id!)"
        cell.student = user
        cell.main = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func getStudentData()
    {
//        mUserData = NSMutableArray()
        var data:[String:Any] = [:]
        if mUserData.count > 0 {
            let user = mUserData.object(at: mUserData.count - 1) as! User
            data = ModelManager.getInstance().getSpecificData("user",user.id! + 1)
        } else {
            data = ModelManager.getInstance().getSpecificData("user",1)
        }
        if data.isEmpty {
            Util.invokeAlertMethod("Users", strBody: "All data Fetched!", delegate: self)
        } else {
            let user: User = Mapper<User>().map(JSONObject: data)!
            mUserData.add(user)
            tblStudentData.reloadData()
        }
    }
    
    func fetchServerData(_ url: String) {
        server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl:  url, strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            
        }, responseDictionary: { (resultDic) in
            DispatchQueue.main.async {
                if resultDic.count > 0 {
                    let user: User = Mapper<User>().map(JSONObject: resultDic)!
                    self.mUserData.add(user)
                    self.tblStudentData.reloadData()
                    let columns = "id,name,username,email,phone,website"
                    let values = "\(user.id!),\'\(user.name!)\',\'\(user.username!)\',\'\(user.email!)\',\'\(user.phone!)\',\'\(user.website!)\'"
                    let acol = "user_id,street,suite,city,zipcode"
                    let aval = "\(user.id!),\'\((user.address?.street!)!)\',\'\((user.address?.suite!)!)\',\'\((user.address?.city!)!)\',\'\((user.address?.zipcode!)!)\'"
                    let gcol = "user_id,lat,lng"
                    let gval = "\(user.id!),\'\((user.address?.geo?.lat!)!)\',\'\((user.address?.geo?.lng!)!)\'"
                    let ccol = "user_id,name,catchPhrase,bs"
                    let cval = "\(user.id!),\'\((user.company?.name!)!)\',\'\((user.company?.catchPhrase!)!)\',\'\((user.company?.bs!)!)\'"
                    
                    if ModelManager.getInstance().addData("user", columns, values) {
                        
                    } else {
                        Util.invokeAlertMethod("User INSERTION", strBody: "Failed!", delegate: self)
                    }
                    if ModelManager.getInstance().addData("address", acol, aval) {
                        
                    } else {
                        Util.invokeAlertMethod("User's address INSERTION", strBody: "Failed!", delegate: self)
                    }
                    if ModelManager.getInstance().addData("geo", gcol, gval) {
                        
                    } else {
                        Util.invokeAlertMethod("User's location INSERTION", strBody: "Failed!", delegate: self)
                    }
                    if ModelManager.getInstance().addData("company", ccol, cval) {
                        
                    } else {
                        Util.invokeAlertMethod("User' company INSERTION", strBody: "Failed!", delegate: self)
                    }
                } else {
                    Util.invokeAlertMethod("Alert", strBody: "all users fetched!", delegate: self)
                }
            }
        }, responseArray: { (resultArr) in
            
        })
    }

}
