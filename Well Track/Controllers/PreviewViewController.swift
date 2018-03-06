//
//  PreviewViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/11/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import AVFoundation

/// View Controller to handle displaying media from the camera view controller.
class PreviewViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    var player = AVQueuePlayer()
    var playerLayer: AVPlayerLayer!
    var playerLooper: AVPlayerLooper!
    
    var videoPreview: Bool = false
    var image: UIImage?
    
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Sets up the video preview layer if a video is passed.
        if videoPreview {
            photo.isHidden = true
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.view.bounds
            playerLayer.videoGravity = .resizeAspect
            self.view.layer.insertSublayer(playerLayer, at: 0)
            self.view.layoutIfNeeded()
            let playItem = AVPlayerItem(url: videoURL!)
            player.replaceCurrentItem(with: playItem)
            playerLooper = AVPlayerLooper(player: player, templateItem: playItem)
            // Automatic loop on video.
            player.play()
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        playerLayer?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photo.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
