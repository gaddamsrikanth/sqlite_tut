//
//  photos.swift
//  sqlite_tut
//
//  Created by devloper65 on 3/22/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import SDWebImage
import ObjectMapper

class photos: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblPhoto: UITableView!
    
    var arrlazy = [Photo]()
    var photoList = NSMutableArray()
    var tempArray = NSArray()
    var count = 10
    var userid = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblPhoto.delegate = self
        tblPhoto.dataSource = self
        tblPhoto.register(UINib(nibName: "photoCell",bundle: nil), forCellReuseIdentifier: "photoCell")
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Profile"
        tblPhoto.rowHeight = UITableViewAutomaticDimension
        tblPhoto.estimatedRowHeight = 140
        DispatchQueue.main.async {
            self.getPhoto()
        }        
    }
    
    //MARK: - TableDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if photoList != nil {
            return photoList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:photoCell = tblPhoto.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! photoCell
        var photo = Photo()
        photo = ((self.photoList.object(at: indexPath.row)) as! Photo)
        if photo.thumbnailUrl != nil {
            cell.imgProPic.sd_setImage(with: URL(string: photo.thumbnailUrl!), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cleanMemory, imageUrl) in
                
            })
        }
        if photo.url != nil {
            cell.imgBackPic.sd_setImage(with: URL(string: photo.url!), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, cleanMemory, imageUrl) in
                
            })
        }
        cell.lbltitle.text = photo.title! + photo.title!
        cell.imgProPic.layer.cornerRadius = cell.imgProPic.frame.height / 2
        cell.imgProPic.layer.borderWidth = 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == photoList.count - 1) {
            if count <= photoList.count {
                count += 10
                lazyload()
            }
        }
    }
    
    //MARK: - Custom Method
    func getPhoto() {
        
        if ModelManager.getInstance().check("photo",userid) {
            self.photoList = ModelManager.getInstance().getAllData("photo",self.count)
            self.photoList = Mapper<Photo>().mapArray(JSONArray: self.photoList as! [[String:Any]]) as! NSMutableArray
            self.tblPhoto.reloadData()
            
        } else {
            
            if server_API.sharedObject.connectedToNetwork() {
                server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl: "photos", strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
                }, responseDictionary: { (resp) in
                    print(resp)
                }) { (result) in
                    
                    self.photoList = Mapper<Photo>().mapArray(JSONArray: result as! [[String:Any]]) as! NSMutableArray
                    self.tblPhoto.reloadData()
                    
                    DispatchQueue.main.async {
                        
                        for i in 0..<self.photoList.count{
                            let string = "photo"
                            let col = "id,albumId,title,url,thumbnailUrl"
                            let str1 = "\(((self.photoList.object(at: i)) as! Photo).id!),\((self.photoList.object(at: i) as! Photo).albumId!),'\((self.photoList.object(at: i) as! Photo).title!)','\((self.photoList.object(at: i) as! Photo).url!)','\((self.photoList.object(at: i) as! Photo).thumbnailUrl!)'"
                            if ModelManager.getInstance().addData(string,col,str1) {
                                //Util.invokeAlertMethod("Success", strBody: "Inserted", delegate: self)
                            } else {
                                Util.invokeAlertMethod("Failed", strBody: "failed", delegate: self)
                            }
                        }
                        self.tblPhoto.reloadData()
                    }
                }
            }
        }
    }
    
    func lazyload() {
        
        let string = "photo"
        photoList = ModelManager.getInstance().getAllData(string,count)
        self.photoList = Mapper<Photo>().mapArray(JSONArray: self.photoList as! [[String:Any]]) as! NSMutableArray
        self.tblPhoto.reloadData()
        
    }
    
}
