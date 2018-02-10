//
//  LogCreationViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

class LogCreationViewController: UIViewController {
    
    @IBOutlet weak var segBtns: UISegmentedControl!
    @IBOutlet weak var pickerview: UIPickerView!
    @IBOutlet weak var txtContainer: UIView!
    @IBOutlet weak var photoCont: UIView!
    @IBOutlet weak var videoCont: UIView!
    @IBOutlet weak var heartrateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    var dummy: UITextField = UITextField(frame: CGRect.zero)
    
    var selectedAfterDecimal: Int = 0
    var selectedBeforeDecimal: Int = 0
    var selectedScale: String = "F"
    
    var scale: [String] = ["F", "C"]
    var beforeDecimal: [Int] = []
    var afterDecimal: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRange(scale: selectedScale)
        
        txtContainer.isHidden = false
        photoCont.isHidden = true
        videoCont.isHidden = true
        pickerview.isHidden = true
        
        pickerview.delegate = self
        pickerview.dataSource = self
        
        temperatureLabel.text = "--.- °\(selectedScale)"
        heartrateLabel.text = "--- BPM"
        temperatureLabel.textColor = .gray
        heartrateLabel.textColor = .gray
        
        dummy = UITextField(frame: CGRect.zero)
        dummy.inputView = pickerview
        dummy.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateRange(scale: String) {
        beforeDecimal = []
        if (scale == "F") {
            for i in 85...110 {
                beforeDecimal.append(i)
            }
        } else {
            for i in 29...44 {
                beforeDecimal.append(i)
            }
        }
    }
    
    @IBAction func ratingSelected(_ sender: UITapGestureRecognizer) {
        if let selected = sender.view as? UIStackView {
            selected.arrangedSubviews[0].tintColor = .red
            if let text = selected.arrangedSubviews[1] as? UILabel {
                text.textColor = .red
            }
        }
    }
    
    @IBAction func temperaturePressed(_ sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func heartratePressed ( _ sender: UITapGestureRecognizer) {
        
    }
    
    @IBAction func saveLogPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func segmentselected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            txtContainer.isHidden = false
            photoCont.isHidden = true
            videoCont.isHidden = true
            break
        case 1:
            txtContainer.isHidden = true
            photoCont.isHidden = false
            videoCont.isHidden = true
            break
        case 2:
            txtContainer.isHidden = true
            photoCont.isHidden = true
            videoCont.isHidden = false
            break
        default:
            break
        }
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

extension LogCreationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return beforeDecimal.count
        case 1:
            return 1
        case 2:
            return afterDecimal.count
        case 3:
            return scale.count
        default:
            return -1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedBeforeDecimal = beforeDecimal[row]
            break
        case 1:
            break
        case 2:
            selectedAfterDecimal = afterDecimal[row]
            break
        case 3:
            if scale[row] != selectedScale {
                selectedScale = scale[row]
                generateRange(scale: scale[row])
                pickerview.reloadComponent(0)
            }
            break
        default:
            break
        }
        temperatureLabel.text = "\(selectedBeforeDecimal).\(selectedAfterDecimal) °\(selectedScale)"
        temperatureLabel.textColor = .black
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(beforeDecimal[row])
        case 1:
            return "."
        case 2:
            return String(afterDecimal[row])
        case 3:
            return scale[row]
        default:
            return ""
        }
    }
}
