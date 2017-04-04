import UIKit
import Photos
import PhotosUI
import Firebase

class MediaSelectorVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var view1: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSelectedItems: UILabel!
    @IBOutlet var CltnVW: UICollectionView!
    @IBOutlet var checkBtn: UIButton!

    
    var type: Int!
    var selectedAssets: [PHAsset]! = []
    var result: PHFetchResult<PHAsset>!
    fileprivate let imageManager = PHCachingImageManager()
    var fetchResult: PHFetchResult<PHAsset>!
    fileprivate var previousPreheatRect = CGRect.zero
    var mulSelection: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch type {
        case 1:
            lblTitle.text = "VIDEOS"
            break
        default:
            lblTitle.text = "IMAGES"
            break
        }
        
        PHPhotoLibrary.shared().register(self)
        
        fetchAssest()
        
        CltnVW.delegate = self
        CltnVW.dataSource = self
        CltnVW.register(UINib(nibName: "AssestCell", bundle: nil), forCellWithReuseIdentifier: "AssestCell")
        CltnVW.allowsSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: CollectionView DataSource and Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return result.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssestCell", for: indexPath) as! AssestCell
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.selectorMethod))
        cell.addGestureRecognizer(longPress)
        
        let asset = result.object(at: indexPath.item)
        switch type {
        case 1:
            let width: CGFloat = 105
            let height: CGFloat = 105
            let size = CGSize(width:width, height:height)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, userInfo) -> Void in
                
                cell.imgView.image = image
                cell.lblText.text = String(format: "%02d:%02d",Int((asset.duration / 60)),Int(asset.duration) % 60)
                cell.checked = false
            }
            break
        default:
            cell.imgView.image = getAssetThumbnail(asset: asset)
            cell.lblText.text = ""
            cell.checked = false
            break
        }
        if mulSelection! {
            cell.checkBoxImgVW.isHidden = false
        } else {
            cell.checkBoxImgVW.isHidden = true
        }
        cell.checkBoxImgVW.image = UIImage(named: "unchecked")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AssestCell
        if mulSelection! {
            if cell.checked! {
                cell.checkBoxImgVW.image = UIImage(named: "unchecked")
                selectedAssets = selectedAssets.filter{$0 != result.object(at: indexPath.item)}
            } else {
                cell.checkBoxImgVW.image = UIImage(named: "checked")
                selectedAssets.append(result.object(at: indexPath.item))
            }
            cell.checked = !cell.checked
        } else {
            switch type {
            case 1:
                let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ChatVC
                DispatchQueue.main.async {
                    if let key = vc.sendVideoMessage() {
                        // 4
                        self.result.object(at: indexPath.item).requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                            let videoFileUrl = (contentEditingInput?.audiovisualAsset as! AVURLAsset).url.absoluteString
                            // 5
                            let path = "\((FIRAuth.auth()?.currentUser?.uid)!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(self.result.object(at: indexPath.item).value(forKey: "filename")!)"
                            
                            // 6
                            vc.storageRef.child(path).putFile(URL(string: videoFileUrl)!, metadata: nil) { (metadata, error) in
                                if let error = error {
                                    print("Error uploading photo: \(error.localizedDescription)")
                                    return
                                }
                                // 7
                                vc.setVideoURL(vc.storageRef.child((metadata?.path)!).description, forVideoMessageWithKey: key)
                            }
                        })
                    }
                }
                if let nav = self.navigationController {
                    nav.popViewController(animated: true)
                }
                break
            default:
                let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ChatVC
                DispatchQueue.main.async {
                    if let key = vc.sendPhotoMessage() {
                        // 4
                        self.result.object(at: indexPath.item).requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                            let imageFileURL = contentEditingInput?.fullSizeImageURL
                            
                            // 5
                            let path = "\((FIRAuth.auth()?.currentUser?.uid)!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(self.result.object(at: indexPath.item).value(forKey: "filename")!)"
                            
                            // 6
                            vc.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                                if let error = error {
                                    print("Error uploading photo: \(error.localizedDescription)")
                                    return
                                }
                                // 7
                                vc.setImageURL(vc.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                            }
                        })
                    }
                }
                if let nav = self.navigationController {
                    nav.popViewController(animated: true)
                }
                break
            }
        }

    }
    
    func selectorMethod(){
        CltnVW.allowsMultipleSelection = true
    }
    
    //MARK: IBAction methods
    @IBAction func sendAssets(_ sender: Any) {
        let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! ChatVC
        DispatchQueue.main.async {
            for pic in self.selectedAssets {
                if let key = vc.sendPhotoMessage() {
                    pic.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                        let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                        let path = "\((FIRAuth.auth()?.currentUser?.uid)!)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(pic.value(forKey: "filename")!)"
                            vc.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                            if let error = error {
                                print("Error uploading photo: \(error.localizedDescription)")
                                return
                            }
                            vc.setImageURL(vc.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                        }
                    })
                }
            }
        }
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    @IBAction func handleCheckBtn(_ sender: Any) {
        if !mulSelection!{
            checkBtn.setImage(UIImage(named: "checked"), for: .normal)
            mulSelection = true
        } else {
            checkBtn.setImage(UIImage(named: "unchecked"), for: .normal)
            mulSelection = false
        }
        CltnVW.reloadData()
    }
    @IBAction func handleBtnBack(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    //MARK: Custom Methods
    
    func fetchAssest(){
        switch type {
        case 1:
            let allVidOptions = PHFetchOptions()
            allVidOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            allVidOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            result = PHAsset.fetchAssets(with: allVidOptions)
            break
        default:
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            result = PHAsset.fetchAssets(with: allPhotosOptions)
            break
        }
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 105, height: 105), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func getImage(asset: PHAsset) -> UIImage
    {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        
        return thumbnail
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}

// MARK: PHPhotoLibraryChangeObserver
extension MediaSelectorVC: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: result)
            else { return }

        DispatchQueue.main.sync {
            result = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                guard let collectionView = self.CltnVW else { fatalError() }
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                CltnVW!.reloadData()
            }
            resetCachedAssets()
        }
    }
}

