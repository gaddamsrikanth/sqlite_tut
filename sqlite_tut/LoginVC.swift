//
//  LoginVC.swift
//  sqlite_tut
//
//  Created by Devloper30 on 30/03/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var txfUsername: UITextField!
    @IBOutlet var BottomLayoutConstraintBtnLogin: NSLayoutConstraint!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 5
        btnLogin.layer.borderWidth = 3
        btnLogin.layer.borderColor = UIColor.lightGray.cgColor
        txfUsername.layer.cornerRadius = txfUsername.frame.height / 5
        txfUsername.layer.borderWidth = 3
        txfUsername.layer.borderColor = UIColor.lightGray.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        if (txfUsername.text?.isEmpty)! {
            Util.invokeAlertMethod("Required", strBody: "Username required", delegate: self)
        } else {
            //Firebase Authentication
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in // 2
                if let err = error { // 3
                    print(err.localizedDescription)
                    return
                }
                let vc = ChannelListVC()
                vc.senderDisplayName = self.txfUsername.text!
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    // MARK: - Notifications
    
    func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardEndFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        BottomLayoutConstraintBtnLogin.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
    }
    
    func keyboardWillHideNotification(_ notification: Notification) {
        BottomLayoutConstraintBtnLogin.constant = 80
    }
}
