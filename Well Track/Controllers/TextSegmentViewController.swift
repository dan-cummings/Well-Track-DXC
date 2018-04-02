//
//  TextSegmentViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/18/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

/// View controller for the text segment of the log creation view controller.
class TextSegmentViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    var hasBeenEdited = false
    var log: HealthLog?
    var infoCaller = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if infoCaller {
            if let info = log {
                if info.hasText == 1 {
                    textField.text = info.text
                } else {
                    textField.text = "No Text Found For Log."
                    textField.textAlignment = NSTextAlignment.center
                }
                textField.isEditable = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setText(_ text: String?) {
        textField.text = text
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
        /*if !hasBeenEdited {
            textView.text = ""
        }*/
    }
}
