import UIKit
import AVKit
import AVFoundation
class VideoPlayerVC: UIViewController {

    var url: URL!
    var player: AVPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        player = AVPlayer(url: url!)
        let avplayer = AVPlayerViewController()
        avplayer.player = player
        self.present(avplayer, animated: true) { 
            avplayer.player?.play()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
}
