//
//  InsertRecordVC.swift
//  sqlite_tut
//
//  Created by Devloper30 on 21/03/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit

class InsertRecordVC: UIViewController {

    @IBOutlet var txfName: UITextField!
    @IBOutlet var txfId: UITextField!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnSave: UIButton!
    
    var isEdit:Bool! = false
    var student: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if isEdit! {
//            txfName.text = self.student.Name
//            txfId.text = self.student.Marks
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleBtnSave(_ sender: Any) {
        if !((txfName.text?.isEmpty)!) && !((txfId.text?.isEmpty)!) {
            if !isEdit {
//                let Student = AnyObject()
//                Student.Name = txfName.text!
//                Student.Marks = txfId.text!
//                if ModelManager.getInstance().addStudentData(Student) {
//                    Util.invokeAlertMethod("insert", strBody: "insert Success", delegate: self)
//                    if let nav = self.navigationController {
//                        nav.popViewController(animated: true)
//                    }
//                } else {
//                    Util.invokeAlertMethod("insert", strBody: "insert failed", delegate: self)
//                }
            } else {
                
//                student.Name = txfName.text!
//                student.Marks = txfId.text!
//                if ModelManager.getInstance().updateStudentData(student) {
//                    Util.invokeAlertMethod("Update", strBody: "updated Successfully", delegate: self)
//                    if let nav = self.navigationController {
//                        nav.popViewController(animated: true)
//                    }
//                } else {
//                    Util.invokeAlertMethod("Update", strBody: "Update failed", delegate: self)
//                }
            }
        } else {
            Util.invokeAlertMethod("insert", strBody: "Insert data", delegate: self)
        }
    }
    @IBAction func handleBtnBack(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
}
