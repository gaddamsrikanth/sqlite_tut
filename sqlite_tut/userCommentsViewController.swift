//
//  userCommentsViewController.swift
//  sqlite_tut
//
//  Created by Developer88 on 3/21/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import ObjectMapper

class userCommentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblvw: UITableView!
    var postid : Int!
    var commentList = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblvw.delegate = self
        tblvw.dataSource = self
        tblvw.register(UINib(nibName : "userPostsCell",bundle: nil), forCellReuseIdentifier: "userPostsCell")
        getComments(postid)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblvw.dequeueReusableCell(withIdentifier: "userPostsCell", for: indexPath) as! userPostsCell
        cell.titleLbl.text = commentList[indexPath.row].name
        cell.bodyLbl.text = commentList[indexPath.row].body
        return cell
    }
    
    func getComments(_ id : Int){
        server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl: "comments?postId=\(postid!)", strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            print(status)
        }, responseDictionary: { (resp) in
            print(resp)
        }) { (result) in
            self.commentList = Mapper<Comment>().mapArray(JSONArray: result as! [[String : Any]])!
            self.tblvw.reloadData()
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    

}
