//
//  userPosts.swift
//  sqlite_tut
//
//  Created by Developer88 on 3/21/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import ObjectMapper

class userPosts: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    var postList = NSMutableArray()
    var userId : Int!
    var i = 0
    var size = 0
    var filteredTableData = [String]()
    var filter = [String]()
    var resultSearchController = UISearchController()
    var col = "bl"
    var isSearch: Bool = false
    
    @IBOutlet var v1: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var lbl1: UILabel!
    @IBOutlet var tblvw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        definesPresentationContext = true
        tblvw.dataSource = self
        tblvw.delegate = self
        tblvw.register(UINib(nibName : "userPostsCell",bundle : nil), forCellReuseIdentifier: "userPostsCell")
        self.title = "Posts"
        userId = 1
        self.lbl1.text = "User :\(userId!)"
        self.tblvw.rowHeight = UITableViewAutomaticDimension
        self.tblvw.estimatedRowHeight = 50;
        DispatchQueue.main.async {
        self.getposts()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.view.addSubview(v1)
        self.view.bringSubview(toFront: v1)
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.isSearch = false
        self.tblvw.reloadData()
        size = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchBar.text = ""
        self.isSearch = false
        searchBar.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        v1.frame = CGRect(x: 0, y: view.frame.height - 50, width: view.frame.width, height: 50)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearch){
            return filter.count
        } else {
        return postList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblvw.dequeueReusableCell(withIdentifier: "userPostsCell", for: indexPath) as! userPostsCell
        switch size {
        case 4 :
            cell.pclbl.font = UIFont(name: cell.pclbl.font.fontName, size:CGFloat(17))
            cell.lbl1.font = UIFont(name: cell.lbl1.font.fontName, size:CGFloat(17))
            break
            
        case 1:
             cell.pclbl.font = UIFont(name: cell.pclbl.font.fontName, size:CGFloat(10 + i))
             cell.lbl1.font = UIFont(name: cell.lbl1.font.fontName, size:CGFloat(10 + i))
            break
        case 2:
            cell.pclbl.font = UIFont(name: cell.pclbl.font.fontName, size:CGFloat(18 + i))
            cell.lbl1.font = UIFont(name: cell.lbl1.font.fontName, size:CGFloat(18 + i))
            break
        case 3:
            cell.pclbl.font = UIFont(name: cell.pclbl.font.fontName, size:CGFloat(24 + i))
            cell.lbl1.font = UIFont(name: cell.lbl1.font.fontName, size:CGFloat(24 + i))
            break
        default:
             cell.pclbl.font = UIFont(name: cell.pclbl.font.fontName, size:CGFloat(17 + i))
            cell.lbl1.font = UIFont(name: cell.lbl1.font.fontName, size:CGFloat(17 + i))
        }
        
        switch col {
        case "r":
            cell.pclbl.textColor = UIColor.red
            cell.lbl1.textColor = UIColor.red
            break
        case "g":
            cell.pclbl.textColor = UIColor.green
            cell.lbl1.textColor = UIColor.green
            break
        case "b":
            cell.pclbl.textColor = UIColor.blue
            cell.lbl1.textColor = UIColor.blue
            break
        default:
            cell.pclbl.textColor = UIColor.black
            cell.lbl1.textColor = UIColor.black
        }
        
        if(isSearch && searchBar.text != ""){
            cell.pclbl.text = String(describing: (self.filter[indexPath.row]))
            cell.pclbl.numberOfLines = 0
        } else {
            cell.pclbl.text = (self.postList.object(at: indexPath.row) as! Post).body
            cell.pclbl.numberOfLines = 0

        }
                return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = userCommentsViewController()
        vc.postId = (self.postList.object(at: indexPath.row) as! Post).id!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func getposts(){
        if(ModelManager.getInstance().check("post","userId",userId!)){
            postList = ModelManager.getInstance().getAllData("post")
            postList = Mapper<Post>().mapArray(JSONArray: postList as! [[String:Any]]) as! NSMutableArray
            for i in 0..<postList.count{
                filteredTableData.append((self.postList.object(at: i) as! Post).body!)
            }

            tblvw.reloadData()
        } else {
        if(server_API.sharedObject.connectedToNetwork()){
        server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl: "posts?userId=\(userId!)", strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            print(status)
        }, responseDictionary: { (NSMutableDictionary) in
            print("")
        }) { (result) in
           self.postList = (Mapper<Post>().mapArray(JSONArray: result as! [[String : Any]])!) as! NSMutableArray
            for i in 0..<self.postList.count{
            let string = "post"
            let col = "id,userId,title,body"
            let str1 = "\(((self.postList.object(at: i)) as! Post).id!),\((self.postList.object(at: i) as! Post).userId!),'\((self.postList.object(at: i) as! Post).title!)','\((self.postList.object(at: i) as! Post).body!)'"
                if ModelManager.getInstance().addData(string,col,str1) {
                    
                } else {
                    
                    }
                self.tblvw.reloadData()
                }
            }
            
        } else {
            postList = ModelManager.getInstance().getAllData("post")
        postList = Mapper<Post>().mapArray(JSONArray: postList as! [[String:Any]]) as! NSMutableArray
            for i in 0..<postList.count{
                filteredTableData.append((self.postList.object(at: i) as! Post).body!)
            }

            tblvw.reloadData()
            }
        }
    }
    
    @IBAction func small(_ sender: Any) {
        self.lbl1.font = self.lbl1.font.withSize(CGFloat(10 + i))
        size = 1
        self.tblvw.reloadData()
    }
    
    @IBAction func med(_ sender: Any) {
        self.lbl1.font = self.lbl1.font.withSize(CGFloat(18 + i))
        size = 2
        self.tblvw.reloadData()

    }
    
    @IBAction func lrge(_ sender: Any) {
        self.lbl1.font = self.lbl1.font.withSize(CGFloat(24 + i))
        size = 3
        self.tblvw.reloadData()

    }
    
    @IBAction func resetFont(_ sender: Any) {
        i = 0
        self.lbl1.textColor = UIColor.black
        col = "bl"
        self.lbl1.font = self.lbl1.font.withSize(17)
        size = 4
        self.tblvw.reloadData()
    }
    
    @IBAction func red(_ sender: Any) {
        self.lbl1.textColor = UIColor.red
        col = "r"
        self.tblvw.reloadData()

    }
    
    @IBAction func green(_ sender: Any) {
        self.lbl1.textColor = UIColor.green
        col = "g"
        self.tblvw.reloadData()

    }
    
    @IBAction func blue(_ sender: Any) {
        self.lbl1.textColor = UIColor.blue
        col = "b"
        self.tblvw.reloadData()

    }
    
    @IBAction func minus(_ sender: Any) {
        i = i - 1
        self.tblvw.reloadData()
    }
    
    @IBAction func plus(_ sender: Any) {
        i = i + 1
        self.tblvw.reloadData()
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
            self.searchBar.text = ""
            self.searchBar.showsCancelButton = false
            self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.isSearch = false
            tblvw.reloadData()
        } else {
                self.isSearch = true
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
