//
//  PhotoSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseStorage

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
