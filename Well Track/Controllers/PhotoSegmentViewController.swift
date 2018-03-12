//
//  PhotoSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PhotoSegmentViewController: UIViewController {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    fileprivate let reuseIdentifier = "MediaCell"
    
    var ref: DatabaseReference!
    var storeRef: StorageReference!
    var log: HealthLog!
    var uid: String!
    
    var editMode = false
    
    var newItems: [MediaItems]?
    
    var infoView = false
    var data: [MediaItems]? {
        didSet {
            DispatchQueue.main.async {
                self.collection.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoBtn.imageView?.contentMode = .scaleAspectFit
        if infoView {
            self.photoBtn.isHidden = true
            self.removeButton.isHidden = true
        }
        self.removeButton.isHidden = true
        self.collection.delegate = self
        self.collection.dataSource = self
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func removePressed(_ sender: UIButton) {
        self.editMode = !self.editMode
        if self.editMode {
            self.removeButton.setTitle("Cancel", for: UIControlState.normal)
        } else {
            self.removeButton.setTitle("Remove", for: UIControlState.normal)
        }
    }
    
    func removeSelectedPicture(item: MediaItems) {
        Storage.storage().reference(forURL: item.imageURL!).delete { (error) in
            guard let _ = error else {
                print("Error removing photo from storage")
                return
            }
            print("Photo removed from storage")
        }
        ref.child(item.key!).removeValue()
    }

    @IBAction func photoBtnPressed(_ sender: Any) {
        if let parent = self.parent as? LogCreationViewController {
            parent.startCamera(self)
        }
    }
    
    func startFirebase(uid: String, log: HealthLog) {
        self.log = log
        self.uid = uid
        ref = Database.database().reference(withPath: "\(uid)/Logs/\(log.key!)/Pictures")
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
    
    func addPhotoToFirebase(_ image: UIImage) {
        var mediaItem = MediaItems()
        mediaItem.key = self.ref.childByAutoId().key
        do {
            let tempURL = self.tempURL()
            try UIImageJPEGRepresentation(image, 0.8)?.write(to: tempURL!)
            self.saveMediaFileToFirebase(type: 1, media: tempURL, saveRefClosure: { (downloadURL) in
                mediaItem.imageURL = downloadURL
                let vals = self.toDictionary(mediaItem)
                self.ref.child(mediaItem.key!).setValue(vals)
                })
        } catch {
            print(error.localizedDescription)
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
    
    func toDictionary(_ item: MediaItems) -> NSMutableDictionary {
        return [
            "imageURL": item.imageURL! as NSString,
            "videoURL": item.videoURL! as NSString,
            "duration": item.duration! as NSNumber
        ]
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

extension PhotoSegmentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WellTrackMediaCollectionViewCell {
            if editMode {
                self.removeSelectedPicture(item: cell.data)
            } else {
                let previewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "photopreview") as! PreviewViewController
                previewController.hideButton = true
                previewController.image = cell.image.image
                self.navigationController?.pushViewController(previewController, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = data?.count {
            if !infoView {
                self.removeButton.isHidden = false
            }
            self.collection.backgroundView = nil
            return count
        } else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: collection.bounds.size.width, height: collection.bounds.size.height))
            label.text = "No pictures have been added to this log"
            label.textColor = .black
            label.textAlignment = .center
            self.collection.backgroundView = label
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
