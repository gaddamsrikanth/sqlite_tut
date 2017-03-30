import UIKit
import Firebase
import ObjectMapper

class ChannelListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: Properties
    var senderDisplayName: String?
    private var channels: [Channel] = []
    
    @IBOutlet var btnCreate: UIButton!
    @IBOutlet var txfNewChannelName: UITextField!
    @IBOutlet var tblChannelList: UITableView!
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    private var channelRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        tblChannelList.delegate = self
        tblChannelList.dataSource = self
        tblChannelList.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        
        observeChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Firebase related methods
    private func observeChannels() {
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            var channelData = snapshot.value as! Dictionary<String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String!, name.characters.count > 0 {
                channelData["id"] = id as AnyObject?
                self.channels.append(Mapper<Channel>().map(JSON: channelData)!)
                self.tblChannelList.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    
    @IBAction func handleBtnCreateNew(_ sender: Any) {
        if let name = txfNewChannelName?.text {
            let newChannelRef = channelRef.childByAutoId()
            let channelItem = [
                "name": name
            ]
            newChannelRef.setValue(channelItem)
        }
        tblChannelList.reloadData()
    }
    
    //MARK: TableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        print("Channel Selected: \(channel.name!)")
        let vc = ChatVC()
        vc.channel = channel
        vc.senderDisplayName = senderDisplayName
        vc.channelRef = channelRef.child(channel.id!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
        cell.lblChannelName.text = channels[indexPath.row].name!
        return cell
    }
    
}
