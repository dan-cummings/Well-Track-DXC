//
//  PreviewViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/11/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import FirebaseStorage

class PreviewViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var player: AVPlayer!
    var playerController: AVPlayerViewController!
    
    var videoPreview: Bool = false
    var hideButton: Bool!
    var videoToLoad: String?
    var image: UIImage?
    
    var videoURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = hideButton
        if videoPreview {
            playerController = AVPlayerViewController()
            if let videoString = videoToLoad {
                if let video = URL(string: videoString) {
                    player = AVPlayer(url: video)
                }
            } else {
                player = AVPlayer(url: videoURL)
            }
            playerController.player = player
            self.addChildViewController(playerController)
            self.view.addSubview(playerController.view)
            playerController.view.frame = self.view.frame
            
            player.play()
        }
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
