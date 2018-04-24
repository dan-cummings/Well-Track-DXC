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


/// View controller which handles the storage and presentation of the photo feature of the well track app. Controllers allows users to add photos and remove existing ones from the current health log.
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
    var removal: DatabaseHandle?
    
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
        self.view.backgroundColor = BACKGROUND_COLOR_DARK
        collection.backgroundColor = BACKGROUND_COLOR
        photoBtn.titleLabel?.textColor = BACKGROUND_COLOR
        photoBtn.backgroundColor = TEXT_DEFAULT_COLOR
        photoBtn.imageView?.tintColor = BACKGROUND_COLOR
        removeButton.titleLabel?.textColor = BACKGROUND_COLOR
        removeButton.backgroundColor = TEXT_DEFAULT_COLOR
        photoBtn.layer.cornerRadius = 7
        removeButton.layer.cornerRadius = 7
        collection.layer.cornerRadius = 7
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
    
    
    /// If remove button is pressed the current photo is discarded and the add photo options are displayed to the user in the segment.
    ///
    /// - Parameter sender: The remove photo button.
    @IBAction func removePressed(_ sender: UIButton) {
        self.editMode = !self.editMode
        if self.editMode {
            self.removeButton.setTitle("Cancel", for: UIControlState.normal)
        } else {
            self.removeButton.setTitle("Remove", for: UIControlState.normal)
        }
    }
    
    func removeSelectedPicture(item: MediaItems) {
        guard let _ = item.key else {
            var tempData = [MediaItems]()
            for picture in self.data! {
                if picture.imageURL != item.imageURL {
                    tempData.append(picture)
                }
            }
            self.data = tempData
            return
        }
        
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
    
    /// Function to get a new URL object for our image.
    ///
    /// - Returns: URL for photo.
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".png")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func addPhoto(_ image: UIImage) {
        
        var newPhotoItem = MediaItems()
        
        newPhotoItem.imageURL = tempURL()?.absoluteString
        imageCache.setObject(image, forKey: newPhotoItem.imageURL as AnyObject)
        
        var tempData = [MediaItems]()
        
        if let loadedData = self.data {
            for item in loadedData {
                tempData.append(item)
            }
            tempData.append(newPhotoItem)
        } else {
            tempData.append(newPhotoItem)
        }
        self.data = tempData
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
            label.textColor = TEXT_DEFAULT_COLOR
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
