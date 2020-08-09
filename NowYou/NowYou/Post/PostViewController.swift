//
//  PostViewController.swift
//  NowYou
//
//  Created by Apple on 12/27/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import AVKit

class PostViewController: BaseViewController {

    @IBOutlet weak var vVideo: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    @IBOutlet weak var btnAddUser: UIButton!
    @IBOutlet weak var btnAddHashtag: UIButton!
    @IBOutlet weak var btnAddText: UIButton!
    @IBOutlet weak var btnAddLink: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    
    var capturedImage: UIImage!
    var videoUrl: URL!
    
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        imgThumbnail.image = capturedImage
        
        let gradientView    = GradientView1(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        gradientView.backgroundColor = UIColor.clear
        gradientView.direction = .vertical
        gradientView.mode = .linear
        
        gradientView.colors = [UIColor.black.withAlphaComponent(0.53), UIColor.black.withAlphaComponent(0.87)]
        
        view.addSubview(gradientView)
        
        btnAddUser.setCircular()
        btnAddHashtag.setCircular()
        btnAddText.setCircular()
        btnAddLink.setCircular()
        btnSend.setCircular()
        
        if videoUrl != nil {
            imgThumbnail.isHidden = true
            playVideo()
            
            // repeat play
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
                self.player?.seek(to: CMTime.zero)
                self.player?.play()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func playVideo() {
        player = AVPlayer(url: videoUrl)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        vVideo.layer.insertSublayer(playerLayer, at: 0)
//        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - filter
    
    @IBAction func onAddUser(_ sender: Any) {
    }
    
    @IBAction func onAddHashtag(_ sender: Any) {
    }
    
    @IBAction func onAddLink(_ sender: Any) {
    }
    
    @IBAction func onAddText(_ sender: Any) {
        
    }
    
    @IBAction func onSend(_ sender: Any) {
    }
    
}
