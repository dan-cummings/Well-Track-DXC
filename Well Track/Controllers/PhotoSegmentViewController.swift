//
//  PhotoSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseStorage


/// View controller which handles the storage and presentation of the photo feature of the well track app. Controllers allows users to add photos and remove existing ones from the current health log.
class PhotoSegmentViewController: UIViewController {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var image: UIImage?
    var infoView = false
    var log: HealthLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// If remove button is pressed the current photo is discarded and the add photo options are displayed to the user in the segment.
    ///
    /// - Parameter sender: The remove photo button.
    @IBAction func removePressed(_ sender: UIButton) {
        image = nil
        photo.image = nil
        photo.isHidden = true
        removeButton.isHidden = true
        label.isHidden = false
        photoBtn.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //If there is a current log this will retrieve the photo from firebase storage
        //so long as it is less than 16MB in size. (Most photos stored are between 1-3MB)
        if infoView {
            if let info = log, info.hasPicture == 1 {
                let storageRef = Storage.storage().reference(forURL: info.pictureURL!)
                storageRef.getData(maxSize: 16 * 1024 * 1024, completion: { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.image = UIImage(data: data!)
                        self.photoBtn.isHidden = true
                        self.photo.image = self.image
                        self.photo.isHidden = false
                        self.label.isHidden = true
                        self.removeButton.isHidden = true
                    }
                })
            } else {
                photoBtn.isHidden = true
                removeButton.isHidden = true
            }
        } else {
            if let _ = image {
                removeButton.isHidden = false
                photo.isHidden = false
                photoBtn.isHidden = true
                label.isHidden = true
            } else {
                removeButton.isHidden = true
                photo.isHidden = true
            }
        }
    }
    
    
    /// Adds the provided image to the UIImageView.
    ///
    /// - Parameter image: Image to display in the UIImageView.
    func setImage(image: UIImage?) {
        self.image = image
        self.photo.image = image
    }

    @IBAction func photoBtnPressed(_ sender: Any) {
        let parent = self.parent as? LogCreationViewController
        parent!.startCamera(self)
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
