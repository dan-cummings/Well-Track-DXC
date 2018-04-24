//
//  VideoSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/17/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

/// View Controller for the video segment of the log creation to handle displaying or adding a video to this log item.
class VideoSegmentViewController: UIViewController {

    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate let reuseIdentifier = "MediaCell"
    
    fileprivate var ref: DatabaseReference!
    fileprivate var storeRef: StorageReference!
    fileprivate var uid: String!

    var infoView = false
    var editMode = false
    var log: HealthLog!
    
    var data: [MediaItems]? {
        didSet {
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = BACKGROUND_COLOR_DARK
        collection.backgroundColor = BACKGROUND_COLOR
        addBtn.titleLabel?.textColor = BACKGROUND_COLOR
        addBtn.backgroundColor = TEXT_DEFAULT_COLOR
        addBtn.imageView?.tintColor = BACKGROUND_COLOR
        removeBtn.titleLabel?.textColor = BACKGROUND_COLOR
        removeBtn.backgroundColor = TEXT_DEFAULT_COLOR
        addBtn.layer.cornerRadius = 7
        removeBtn.layer.cornerRadius = 7
        collection.layer.cornerRadius = 7
        self.addBtn.imageView?.contentMode = .scaleAspectFit
        if infoView {
            addBtn.isHidden = true
            removeBtn.isHidden = true
        }
        self.collection.delegate = self
        self.collection.dataSource = self
        collection.allowsSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = ref {
            registerForFirebase()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = ref {
            ref.removeAllObservers()
        }
    }
    
    func startFirebase(uid: String, log: HealthLog) {
        self.log = log
        self.uid = uid
        ref = Database.database().reference(withPath: "\(uid)/Logs/\(log.key!)/Videos")
        storeRef = Storage.storage().reference()
        self.registerForFirebase()
    }

    fileprivate func registerForFirebase() {
        if self.data == nil || self.infoView {
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let values = snapshot.value as? [String : AnyObject] {
                    var tmpItems = [MediaItems]()
                    for (_,val) in values.enumerated() {
                        let entry = val.1 as! Dictionary<String,AnyObject>
                        let key = val.0
                        let videoURL = entry["videoURL"] as! String
                        let duration = Double(truncating: entry["duration"] as! NSNumber)
                        let imageURL = entry["imageURL"] as! String
                        tmpItems.append(MediaItems(key: key, videoURL: videoURL, duration: duration, imageURL: imageURL))
                    }
                    self.data = tmpItems
                }})
        }
        
        ref.observe(.childRemoved, with: { (snapshot) in
            var tempItems = [MediaItems]()
            for item in self.data! {
                if snapshot.key != item.key {
                    tempItems.append(item)
                }
            }
            self.data = tempItems
        })
    }
    
    func getThumbnail(forURL url: URL) -> (Float64?, UIImage?)? {
        do {
            let asset = AVAsset(url: url)
            let duration = asset.duration
            let thumbnailImage = try AVAssetImageGenerator(asset: AVAsset(url: url)).copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            return (CMTimeGetSeconds(duration), UIImage(cgImage: thumbnailImage))
        } catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func addVideo(_ video: URL?) {
        var newVideoItem = MediaItems()
        let thumbnail = self.getThumbnail(forURL: video!)
        newVideoItem.videoURL = video?.absoluteString
        videoCache.setObject(video as AnyObject, forKey: video?.absoluteString as AnyObject)
        newVideoItem.imageURL = self.tempURL()?.absoluteString
        imageCache.setObject(thumbnail!.1!, forKey: newVideoItem.imageURL as AnyObject)
        
        newVideoItem.duration = thumbnail?.0
        
        var tempData = [MediaItems]()
        
        if let loadedData = self.data {
            for item in loadedData {
                tempData.append(item)
            }
            tempData.append(newVideoItem)
            
        } else {
            tempData.append(newVideoItem)
        }
        self.data = tempData
    }

    @IBAction func addVideoPressed(_ sender: Any) {
        let parent = self.parent as? LogCreationViewController
        parent?.startCamera(self)
    }
    
    @IBAction func removeVideo(_ sender: Any) {
        self.editMode = !self.editMode
        if self.editMode {
            self.removeBtn.setTitle("Cancel", for: UIControlState.normal)
        } else {
            self.removeBtn.setTitle("Remove", for: UIControlState.normal)
        }
    }
    
    func removeSelectedVideo(item: MediaItems) {
        
        //Remove selected video that is not in firebase
        guard let _ = item.key else {
            var tempData = [MediaItems]()
            for video in self.data! {
                if video.imageURL != item.imageURL {
                    tempData.append(video)
                }
            }
            self.data = tempData
            return
        }
        
        //Remove firebase video.
        Storage.storage().reference(forURL: item.imageURL!).delete { (error) in
            guard let _ = error else {
                print("Error removing thumbnail from storage")
                return
            }
            print("Thumbnail removed from storage")
        }
        Storage.storage().reference(forURL: item.videoURL!).delete { (error) in
            guard let _ = error else {
                print("Error removing video from storage")
                return
            }
            print("Video removed from storage")
        }
        ref.child(item.key!).removeValue()
    }
    
    
    /// Function to get a new temporary URL object.
    ///
    /// - Returns: Temporary URL optional.
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".png")
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

extension VideoSegmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WellTrackMediaCollectionViewCell {
            if self.editMode {
                // Remove selected cell
                self.removeSelectedVideo(item: cell.data)
            } else {
                // Call preview with the video url
                let previewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "photopreview") as! PreviewViewController
                previewController.videoPreview = true
                previewController.hideButton = true
                previewController.videoToLoad = cell.data.videoURL
                self.navigationController?.pushViewController(previewController, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = data?.count {
            collection.backgroundView = nil
            if !infoView {
                self.removeBtn.isHidden = false
            }
            return count
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: collection.bounds.size.width, height: collection.bounds.size.height))
            label.text = "No videos have been added to this log"
            label.textColor = TEXT_DEFAULT_COLOR
            label.textAlignment = .center
            collection.backgroundView = label
            if !infoView {
                self.removeBtn.isHidden = true
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WellTrackMediaCollectionViewCell
        guard let item = data?[indexPath.row] else {
            return cell
        }
        cell.data = item
        cell.image.loadImageFromCacheUsingURL(urlString: item.imageURL!)
        cell.image.contentMode = .scaleAspectFill
        return cell
    }
}
