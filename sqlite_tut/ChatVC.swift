import UIKit
import Firebase
import JSQMessagesViewController
import Photos
import AVKit
import AVFoundation

class ChatVC: JSQMessagesViewController {

    @IBOutlet var selectorVW: UIView!
    var channelRef: FIRDatabaseReference?
    var channel: Channel?
    var cView,transperentView: UIView!
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    private lazy var messageRef: FIRDatabaseReference = self.channelRef!.child("messages")
    private var newMessageRefHandle: FIRDatabaseHandle?
    private lazy var userIsTypingRef: FIRDatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId) // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    private lazy var usersTypingQuery: FIRDatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://sqlitetut.appspot.com/")
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    private var videoMessageMap = [String: JSQVideoMediaItem]()
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    @IBOutlet var messageImageVW: UIImageView!
    @IBOutlet var vwImageViewer: UIView!
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    //MARK: jsqmessage collection methods
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if message.media is JSQPhotoMediaItem {
                let image = (message.media as! JSQPhotoMediaItem).image!
                messageImageVW.image = image
                vwImageViewer.frame = CGRect(x: (UIScreen.main.bounds.size.width/2) - (image.size.width/10)/2, y: (UIScreen.main.bounds.size.height/2) - (image.size.height/10)/2, width: image.size.width/10, height: image.size.height/10)
                self.transperentView = UIView(frame: UIScreen.main.bounds)
                self.transperentView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                if !self.view.subviews.contains(self.transperentView) {
                    self.view.addSubview(self.transperentView)
                }
                self.view.addSubview(vwImageViewer)
                self.cView = vwImageViewer
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
                tap.cancelsTouchesInView = false
                self.transperentView.addGestureRecognizer(tap)
            } else {
                let player = AVPlayer(url: (message.media as! JSQVideoMediaItem).fileURL)
                let avplayer = AVPlayerViewController()
                avplayer.player = player
                self.present(avplayer, animated: true) {
                    avplayer.player?.play()
                }
            }
        } else {
            Util.invokeAlertMethod("Message Details", strBody: "Sender: \(message.senderDisplayName!)\nMessage: \(message.text)" as NSString, delegate: self)
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    //MARK: message bubble methods
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    //MARK: message methods
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    func sendVideoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "videoURL": "NOTSET",
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setVideoURL(_ url: String, forVideoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["videoURL": url])
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        selectorVW.frame = CGRect(x: 10, y: UIScreen.main.bounds.size.height - 35 - selectorVW.frame.height, width: selectorVW.frame.width, height: selectorVW.frame.height)
        self.transperentView = UIView(frame: UIScreen.main.bounds)
        self.transperentView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        if !self.view.subviews.contains(self.transperentView) {
            self.view.addSubview(self.transperentView)
        }
        self.view.addSubview(selectorVW)
        self.cView = selectorVW
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        tap.cancelsTouchesInView = false
        self.transperentView.addGestureRecognizer(tap)
    }
    
    func tapHandler(){
        self.cView.removeFromSuperview()
        self.transperentView.removeFromSuperview()
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        itemRef.setValue(messageItem) // 3
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        finishSendingMessage() // 5
        isTyping = false
    }
    
    //MARK: message observer
        //MARK: Image Observer
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        // 2
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
                let localpath = "sqlite_tut/images/" + (metadata?.path)!
                let directories = localpath.components(separatedBy: "/").filter{!$0.contains(".")}
                var path:String? = ""
                for dir in 0..<directories.count {
                    path?.append(directories[dir])
                    let fileManager = FileManager.default
                    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(path!)
                    if !fileManager.fileExists(atPath: paths){
                        try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
                    }
                    path?.append("/")
                }
                let fileManager = FileManager.default
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(localpath)
                if (metadata?.contentType == "image/gif") {
                    if !FileManager.default.fileExists(atPath: paths) {
                        print("fetched from server")
                        mediaItem.image = UIImage.gif(data: data!)
                        fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
                    } else {
                        print("fetched from local")
                        mediaItem.image = UIImage.gif(url: paths)
                    }
                } else {
                    if !FileManager.default.fileExists(atPath: paths) {
                        print("fetched from server")
                        mediaItem.image = UIImage.init(data: data!)
                        fileManager.createFile(atPath: paths as String, contents: data, attributes: nil)
                    } else {
                        print("fetched from local")
                        mediaItem.image = UIImage(contentsOfFile: paths)
                    }
                    
                }
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
        //MARK: Video observer
    private func addVideoMessage(withId id: String, key: String, mediaItem: JSQVideoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if mediaItem.fileURL == nil {
                videoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    private func fetchVideoDataAtURL(_ videoURL: String, forMediaItem mediaItem: JSQVideoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = FIRStorage.storage().reference(forURL: videoURL)
        // 2
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
//                FileManager.default.createFile(atPath: "", contents: <#T##Data?#>, attributes: <#T##[String : Any]?#>)
                mediaItem.fileURL = metadata?.downloadURL()
//                mediaItem.fileURL = URL(string: videoURL)
                mediaItem.isReadyToPlay = true
                self.collectionView.reloadData()
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        // 1
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 3 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    private func observeMessages() {
        messageRef = channelRef!.child("messages") // 1.
        let messageQuery = messageRef.queryLimited(toLast:25)
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {  // 4
                self.addMessage(withId: id, name: name, text: text+"\n\(name)")                // 5
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else if let id = messageData["senderId"] as String!,
                let videoURL = messageData["videoURL"] as String! {
                if let mediaItem = JSQVideoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addVideoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if videoURL.hasPrefix("gs://") {
                        self.fetchVideoDataAtURL(videoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            } else if let videoURL = messageData["videoURL"] as String! {
                if let mediaItem = self.videoMessageMap[key] {
                    self.fetchVideoDataAtURL(videoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    //MARK: IBAction Methods
    
    @IBAction func selectVideo(_ sender: Any) {
        let vc = MediaSelectorVC()
        vc.type = 1
        tapHandler()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let vc = MediaSelectorVC()
        vc.type = 2
        tapHandler()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openCam(_ sender: Any) {
        tapHandler()
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
            present(picker, animated: true, completion:nil)
        } else {
            Util.invokeAlertMethod("Camera", strBody: "Camera is not available right now", delegate: self)
        }
    }
}

// MARK: Image Picker Delegate
extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        // Handle picking a Photo from the Camera - TODO
        // 1
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        // 2
        if let key = sendPhotoMessage() {
            // 3
            let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
            let imagePath = (FIRAuth.auth()!.currentUser!.uid) + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            // 5
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            // 6
            storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error uploading photo: \(error)")
                    return
                }
                // 7
                self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
