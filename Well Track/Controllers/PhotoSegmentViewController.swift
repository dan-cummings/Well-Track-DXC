//
//  PhotoSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/10/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class PhotoSegmentViewController: UIViewController {

    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    var image: UIImage?
    
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
        if let _ = image {
            photo.isHidden = false
            photoBtn.isHidden = true
            label.isHidden = true
        } else {
            removeButton.isHidden = true
            photo.isHidden = true
        }
    }
    
    func setImage(image: UIImage) {
        self.image = image
        self.photo.image = image
    }

    @IBAction func photoBtnPressed(_ sender: Any) {
        let parent = self.parent as? LogCreationViewController
        parent!.startCamera()
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
