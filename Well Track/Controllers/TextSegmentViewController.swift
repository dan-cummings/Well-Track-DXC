//
//  TextSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/18/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class TextSegmentViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    var hasBeenEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getText() -> String? {
        return textField.text
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

extension TextSegmentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        hasBeenEdited = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !hasBeenEdited {
            textView.text = ""
        }
    }
}
