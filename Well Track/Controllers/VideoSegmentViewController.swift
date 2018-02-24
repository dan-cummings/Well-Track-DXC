//
//  VideoSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/17/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage

class VideoSegmentViewController: UIViewController {

    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var player = AVQueuePlayer()
    var playerLayer: AVPlayerLayer!
    var playerLooper: AVPlayerLooper!
    var infoView = false
    var log: HealthLog?
    
    @IBOutlet weak var previewView: UIView!
    
    var video: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if infoView {
            if let info = log, info.hasVideo == 1 {
                let storageRef = Storage.storage().reference(forURL: info.videoURL!)
                let tempUrl = tempURL()
                storageRef.write(toFile: tempUrl!) { url, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.removeBtn.isHidden = true
                        self.previewView.isHidden = false
                        self.addBtn.isHidden = true
                        self.label.isHidden = true
                        self.video = url
                        self.previewView.isHidden = false
                        self.addBtn.isHidden = true
                        self.label.isHidden = true
                        self.playerLayer = AVPlayerLayer(player: self.player)
                        self.playerLayer.frame = self.previewView.bounds
                        self.playerLayer.videoGravity = .resizeAspect
                        self.previewView.layer.insertSublayer(self.playerLayer, at: 0)
                        let playItem = AVPlayerItem(url: self.video!)
                        self.player.isMuted = true
                        self.player.replaceCurrentItem(with: playItem)
                        self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playItem)
                        self.player.play()
                    }
                }
            } else {
                addBtn.isHidden = true
                removeBtn.isHidden = true
            }
        } else {
            if let _ = video {
                removeBtn.isHidden = false
                previewView.isHidden = false
                addBtn.isHidden = true
                label.isHidden = true
                playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = previewView.bounds
                playerLayer.videoGravity = .resizeAspect
                previewView.layer.insertSublayer(playerLayer, at: 0)
                let playItem = AVPlayerItem(url: video!)
                player.isMuted = true
                player.replaceCurrentItem(with: playItem)
                playerLooper = AVPlayerLooper(player: player, templateItem: playItem)
                player.play()
            } else {
                removeBtn.isHidden = true
                previewView.isHidden = true
                addBtn.isHidden = false
                label.isHidden = false
                label.isHidden = false
            }
        }
    }

    @IBAction func addVideoPressed(_ sender: Any) {
        let parent = self.parent as? LogCreationViewController
        parent?.startCamera(self)
    }
    
    @IBAction func removeVideo(_ sender: Any) {
        removeBtn.isHidden = true
        label.isHidden = false
        addBtn.isHidden = false;
        previewView.isHidden = true
        player.removeAllItems()
        playerLooper.disableLooping()
        do {
            try FileManager.default.removeItem(at: video!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupForInfoView(_ info: HealthLog) {
        if info.hasVideo == 1 {
            let storageRef = Storage.storage().reference(forURL: info.videoURL!)
            let tempUrl = tempURL()
            storageRef.write(toFile: tempUrl!) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.video = url
                    self.previewView.isHidden = false
                    self.addBtn.isHidden = true
                    self.label.isHidden = true
                    self.playerLayer = AVPlayerLayer(player: self.player)
                    self.playerLayer.frame = self.previewView.bounds
                    self.playerLayer.videoGravity = .resizeAspect
                    self.previewView.layer.insertSublayer(self.playerLayer, at: 0)
                    let playItem = AVPlayerItem(url: self.video!)
                    self.player.isMuted = true
                    self.player.replaceCurrentItem(with: playItem)
                    self.playerLooper = AVPlayerLooper(player: self.player, templateItem: playItem)
                    self.player.play()
                }
            }
        } else {
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
