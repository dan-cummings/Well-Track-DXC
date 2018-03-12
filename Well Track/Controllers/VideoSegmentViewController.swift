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

class VideoSegmentViewController: UIViewController {

    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate let reuseIdentifier = "MediaCell"
    
    fileprivate var ref: DatabaseReference!
    fileprivate var storeRef: StorageReference!
    fileprivate var uid: String!

    var infoView = false
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
        self.addBtn.imageView?.contentMode = .scaleAspectFit
        if infoView {
            addBtn.isHidden = true
            removeBtn.isHidden = true
        }
        self.collection.delegate = self
        self.collection.dataSource = self
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
        ref.observe(.value, with: { snapshot in
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
    
    func saveMediaFileToFirebase(type: Int, media: URL?, saveRefClosure: @escaping (String) -> ()) {
        let mediaType : String = type == 1 ? "Photos" : "Videos"
        let ext : String = type == 1 ? "jpg" : "mp4"
        let mime : String = type == 1 ? "image/jpeg" : "video/mp4"
        
        do {
            let media = try Data(contentsOf: media!)
            let mediaPath = "\(self.uid!)/\(mediaType)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).\(ext)"
            let metadata = StorageMetadata()
            metadata.contentType = mime
            if let storageRef = self.storeRef {
                storageRef.child(mediaPath).putData(media, metadata: metadata) {(metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error.localizedDescription)")
                        return
                    }
                    saveRefClosure(metadata!.downloadURL()!.absoluteString)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addVideoToFirebase(_ item: URL) {
        var mediaItem = MediaItems()
        
        mediaItem.key = ref.childByAutoId().key
        
        if let info = getThumbnail(forURL: item) {
            let tempURL = self.tempURL()
            mediaItem.duration = info.0
            do {
                try UIImageJPEGRepresentation(info.1!, 0.8)?.write(to: tempURL!)
                self.saveMediaFileToFirebase(type: 1, media: tempURL, saveRefClosure: { (photoURL) in
                    mediaItem.imageURL = photoURL
                    self.saveMediaFileToFirebase(type: 0, media: item, saveRefClosure: { (videoURL) in
                        mediaItem.videoURL = videoURL
                        let vals = self.toDictionary(mediaItem)
                        self.ref.child(mediaItem.key!).setValue(vals)
                    })
                })
            } catch {
                print(error.localizedDescription)
            }
        }
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
    
    func toDictionary(_ item: MediaItems) -> NSMutableDictionary {
        return [
            "imageURL": item.imageURL! as NSString,
            "videoURL": item.videoURL! as NSString,
            "duration": item.duration! as NSNumber
        ]
    }

    @IBAction func addVideoPressed(_ sender: Any) {
        let parent = self.parent as? LogCreationViewController
        parent?.startCamera(self)
    }
    
    @IBAction func removeVideo(_ sender: Any) {
        // Change edit mode on and selected items are removed from firebase.
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

extension VideoSegmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if infoView {
            return
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? WellTrackMediaCollectionViewCell {
            let previewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "photopreview") as! PreviewViewController
            previewController.videoPreview = true
            previewController.hideButton = true
            if let tempURL = tempURL() {
                let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                activityView.center = self.view.center
                activityView.startAnimating()
                
                self.view.addSubview(activityView)
                Storage.storage().reference(forURL: cell.data.videoURL!).write(toFile: tempURL, completion: { (url, error) in
                    guard let _ = error else {
                        return
                    }
                    activityView.stopAnimating()
                    previewController.videoURL = url
                    self.navigationController?.pushViewController(previewController, animated: true)
                })
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
            label.textColor = .black
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
