//
//  PreviewViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/11/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
