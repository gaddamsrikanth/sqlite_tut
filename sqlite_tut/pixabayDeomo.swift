//
//  pixabayDeomo.swift
//  sqlite_tut
//
//  Created by devloper65 on 3/30/17.
//  Copyright © 2017 sqlite. All rights reserved.
//

import UIKit
import SDWebImage
import ObjectMapper

class pixabayDeomo: UIViewController, UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching, SDWebImageManagerDelegate {
    
    @IBOutlet var tblPhoto: UITableView!
    var hitList = NSMutableArray()
    var arrlazy = NSMutableArray()
    var photoList = NSMutableArray()
    var count = 20
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblPhoto.delegate = self
        tblPhoto.dataSource = self
        tblPhoto.prefetchDataSource = self
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
        if arrlazy.count > 0 {
            return arrlazy.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:photoCell = tblPhoto.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! photoCell
        let dic : NSMutableDictionary = (self.arrlazy.object(at: indexPath.row) as? NSMutableDictionary)!
        let name = String(describing: dic.object(forKey: "user")!)
        let url = String(describing: dic.object(forKey: "userImageURL")!)
        let url1 = String(describing: dic.object(forKey: "webformatURL")!)
        if !name.isEmpty {
            cell.lbltitle.text = name
        }
        DispatchQueue.main.async {
            if !url.isEmpty {
                SDWebImagePrefetcher.shared()
                cell.imgProPic.sd_setImage(with: URL(string: url), placeholderImage: nil, options: SDWebImageOptions.cacheMemoryOnly, completed: { (image, error, memory, imageUrl) in
                    
                })
            }
            if !url1.isEmpty {
                cell.imgBackPic.sd_setImage(with: URL(string: url1), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, imageUrl) in
                    
                })
            }
        }
        cell.imgProPic.layer.cornerRadius = cell.imgProPic.frame.height / 2
        cell.imgProPic.layer.borderWidth = 1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row == arrlazy.count - 2) {
            count += 20
            getPhoto()
            self.tblPhoto.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
    }
    
    //    func imageManager(_ imageManager: SDWebImageManager, shouldDownloadImageFor imageURL: URL?) -> Bool {
    //        for i in 0..<arrlazy.count {
    //        let dic : NSMutableDictionary = (self.arrlazy.object(at: i) as? NSMutableDictionary)!
    //        let url = String(describing: dic.object(forKey: "userImageURL")!)
    //        let url1 = String(describing: dic.object(forKey: "webformatURL")!)
    //            imageManager.loadImage(with: url, options: SDWebImageOptions.progressiveDownload, progress: { (i, i, imageURL) in
    //
    //            }
    //                , completed: { (image, data, error, memopry, true, imageURL) in
    //
    //            })
    //        }
    //        return true
    //    }
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let cell: photoCell = tblPhoto.dequeueReusableCell(withIdentifier: "photoCell") as! photoCell
        for i in 0..<indexPaths.count {
            let dic: NSMutableDictionary = (self.arrlazy.object(at: i) as! NSMutableDictionary)
            let url = String(describing: dic.object(forKey: "webformatURL")!)
            let url1 = String(describing: dic.object(forKey: "userImageURL")!)
            SDWebImagePrefetcher.shared().prefetcherQueue.async {
                cell.imgBackPic.sd_setImage(with: URL(string: url), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                    
                })
                
                cell.imgProPic.sd_setImage(with: URL(string: url1), placeholderImage: nil, options: SDWebImageOptions.progressiveDownload, completed: { (image, error, memory, url) in
                    
                })
            }
        }
    }
    
    //MARK: - Custom Method
    func getPhoto() {
        if server_API.sharedObject.connectedToNetwork() {
            server_API.sharedObject.requestFor_NSMutableDictionary(strRequestUrl: "api/?key=4931148-a643c1d1887120cefaa81b642&response_group=image_details&q=cars&page=\(page)&per_page=\(count)", strRequestMethod: "GET", requestParameter: nil, requestParameterImages: nil, isTokenEmbeded: false, status: { (status) in
            }, responseDictionary: { (resp) in
                
                self.hitList = NSMutableArray()
                self.hitList.add(resp)
                self.hitList = Mapper<Hits>().mapArray(JSONArray: self.hitList as! [[String:Any]]) as! NSMutableArray
                
                let hit : Hits = self.hitList.object(at: 0) as! Hits
                self.arrlazy = hit.res!
                DispatchQueue.main.async {
                    self.tblPhoto.reloadData()
                }
                
            }, responseArray: { (result) in
                print(result)
            })
        }
    }
    
    func lazyload() {
        
        let string = "photo"
        photoList = ModelManager.getInstance().getAllData(string,count)
        self.photoList = Mapper<Photo>().mapArray(JSONArray: self.photoList as! [[String:Any]]) as! NSMutableArray
        self.tblPhoto.reloadData()
        
    }
}
