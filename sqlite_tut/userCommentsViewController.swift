//
//  userCommentsViewController.swift
//  sqlite_tut
//
//  Created by Developer88 on 3/21/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import ObjectMapper
import PayPalMobileSDK

class userCommentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, PayPalPaymentDelegate {

    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var resultText = ""
    var payPalConfig = PayPalConfiguration()
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var bck: UIButton!
    @IBOutlet var postlbl: UILabel!
    var filteredTableData = [String]()
    @IBOutlet var tblvw: UITableView!
    var postId : Int!
    var commentList = NSMutableArray()
    var filter = [String]()
    var isSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
        searchBar.delegate = self
        self.navigationController?.navigationBar.isTranslucent = false
        definesPresentationContext = true
        let item = UIBarButtonItem(customView: bck)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        tblvw.delegate = self
        tblvw.dataSource = self
        self.title = "Comments"
        tblvw.register(UINib(nibName : "userPostsCell",bundle: nil), forCellReuseIdentifier: "userPostsCell")
        self.navigationController?.isNavigationBarHidden = false
        self.postlbl.text = "Post No:\(postId!)"
        self.tblvw.rowHeight = UITableViewAutomaticDimension
        self.tblvw.estimatedRowHeight = 50;
        DispatchQueue.main.async {
            self.getComments(self.postId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
            PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            self.resultText = completedPayment.description
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearch){
            return filter.count
        } else {
            return commentList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblvw.dequeueReusableCell(withIdentifier: "userPostsCell", for: indexPath) as! userPostsCell
        cell.lbl1.text = "Comm:"
        if(isSearch && searchBar.text != ""){
            cell.pclbl.text = String(describing: (self.filter[indexPath.row]))
            cell.pclbl.numberOfLines = 0
        } else {
            cell.pclbl.text = (self.commentList.object(at: indexPath.row) as! Comment).body
            cell.pclbl.numberOfLines = 0
            
        }
        
        return cell
    }
    
    func getComments(_ id : Int){
        if(ModelManager.getInstance().check("comment","postId",postId!)){
            commentList = ModelManager.getInstance().getCommentData("comment","\(postId!)")
            commentList = Mapper<Comment>().mapArray(JSONArray: commentList as! [[String:Any]]) as! NSMutableArray

            for i in 0..<commentList.count{
                filteredTableData.append((self.commentList.object(at: i) as! Comment).body!)
            }
            tblvw.reloadData()
        } else {
        if(server_API.sharedObject.connectedToNetwork()){
        server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl: "comments?postId=\(postId!)", strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            print(status)
        }, responseDictionary: { (resp) in
            print(resp)
        }) { (result) in
            self.commentList = (Mapper<Comment>().mapArray(JSONArray: result as! [[String : Any]])!) as! NSMutableArray
            for i in 0..<self.commentList.count{
                self.filteredTableData.append((self.commentList.object(at: i) as! Comment).body!)
            }
            for i in 0..<self.commentList.count{
            let string = "comment"
            let col = "id,postId,name,email,body"
            let str1 = "\(((self.commentList.object(at: i)) as! Comment).id!),\((self.commentList.object(at: i) as! Comment).postId!),'\((self.commentList.object(at: i) as! Comment).name!)','\((self.commentList.object(at: i) as! Comment).email!)','\((self.commentList.object(at: i) as! Comment).body!)'"
                if ModelManager.getInstance().addData(string,col,str1){
                }
                else{
                
                }
            }
            self.tblvw.reloadData()
        }
        } else {
            commentList = ModelManager.getInstance().getCommentData("comment","\(postId!)")
            self.commentList = (Mapper<Comment>().mapArray(JSONArray: commentList as! [[String : Any]])!) as! NSMutableArray
            for i in 0..<commentList.count{
                filteredTableData.append((self.commentList.object(at: i) as! Comment).body!)
            }
            tblvw.reloadData()

            }
        }
    }
    
    
    @IBAction func pay(_ sender: Any) {
        let item1 = PayPalItem(name: "Old jeans with holes", withQuantity: 2, withPrice: NSDecimalNumber(string: "1000"), withCurrency: "USD", withSku: "Hip-0037")
        let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
        let item3 = PayPalItem(name: "Long-sleeve plaid shirt (mustache not included)", withQuantity: 1, withPrice: NSDecimalNumber(string: "37.99"), withCurrency: "USD", withSku: "Hip-00291")
        
        let items = [item1, item2, item3]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "5.99")
        let tax = NSDecimalNumber(string: "2.50")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Hipster Clothing", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            
            print("Payment not processalbe: \(payment)")
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
        self.searchBar.showsCancelButton = true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if isSearch == true{
            isSearch = false
            tblvw.reloadData()
        }
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)!{
            isSearch = false
            tblvw.reloadData()
        } else {
            isSearch = true
            filt()
        }
    }
    
    func filt()
    {
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchBar.text!)
        let array = (filteredTableData as NSArray).filtered(using: searchPredicate)
        filter = array as! [String]
        print(array)
        self.tblvw.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    

}
