import UIKit
import Photos
import PhotosUI

class MediaSelectorVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet var view1: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSelectedItems: UILabel!
    @IBOutlet var CltnVW: UICollectionView!
    
    var type: Int!
    var result: PHFetchResult<PHAsset>!
    fileprivate let imageManager = PHCachingImageManager()
    var fetchResult: PHFetchResult<PHAsset>!
    fileprivate var previousPreheatRect = CGRect.zero
    
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
        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 10)
//        layout.itemSize = CGSize(width: 100, height: 100)
//        
//        CltnVW = UICollectionView(frame: self.CltnVW.frame, collectionViewLayout: layout)
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
        
        let asset = result.object(at: indexPath.row)
        switch type {
        case 1:
            let width: CGFloat = 105
            let height: CGFloat = 105
            let size = CGSize(width:width, height:height)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, userInfo) -> Void in
                
                cell.imgView.image = image
                cell.lblText.text = String(format: "%02d:%02d",Int((asset.duration / 60)),Int(asset.duration) % 60)
                cell.checkBoxImgVW.isHidden = true
                cell.checked = false
            }
            break
        default:
            cell.imgView.image = getAssetThumbnail(asset: asset)
            cell.lblText.text = ""
            cell.checked = false
            cell.checkBoxImgVW.isHidden = true
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.allowsMultipleSelection {
            let cell = collectionView.cellForItem(at: indexPath) as! AssestCell
            if cell.checkBoxImgVW.isHidden {
                cell.checkBoxImgVW.isHidden = false
                cell.checkBoxImgVW.image = UIImage(named: "checked")
                cell.checked = true
            } else {
                if cell.checked! {
                    cell.checkBoxImgVW.image = UIImage(named: "unchecked")
                    cell.checked = false
                } else {
                    cell.checked = true
                    cell.checkBoxImgVW.image = UIImage(named: "checked")
                }
            }
            
        } else {
            
        }
    }
    
    func selectorMethod(){
        CltnVW.allowsMultipleSelection = true
    }
    
    //MARK: IBAction methods
    @IBAction func sendAssets(_ sender: Any) {
        
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

