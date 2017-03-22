//
//  userPosts.swift
//  sqlite_tut
//
//  Created by Developer88 on 3/21/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import ObjectMapper

class userPosts: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var postList = [Post]()
    var postid : Int!
    
    @IBOutlet var tblvw: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblvw.dataSource = self
        tblvw.delegate = self
        tblvw.register(UINib(nibName : "userPostsCell",bundle: nil), forCellReuseIdentifier: "userPostsCell")
        self.navigationController?.isNavigationBarHidden = true
        getposts()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblvw.dequeueReusableCell(withIdentifier: "userPostsCell", for: indexPath) as! userPostsCell
        cell.titleLbl.text = postList[indexPath.row].title
        cell.bodyLbl.text = postList[indexPath.row].body
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = userCommentsViewController()
        vc.postid = postList[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getposts(){
        server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl: "posts?userId=\(postid)", strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            print(status)
        }, responseDictionary: { (NSMutableDictionary) in
            print("")
        }) { (result) in
            self.postList = Mapper<Post>().mapArray(JSONArray: result as! [[String : Any]])!
            self.tblvw.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
            }

}
