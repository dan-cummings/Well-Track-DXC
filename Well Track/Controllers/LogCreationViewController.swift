//
//  LogCreationViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

protocol LogCreationViewDelegate {
    func saveLog(log: HealthLog, picture: UIImage?, video: URL?)
}

class LogCreationViewController: UIViewController {
    
    @IBOutlet weak var pickerStack: UIStackView!
    @IBOutlet weak var imageStack: UIStackView!
    @IBOutlet weak var segBtns: UISegmentedControl!
    @IBOutlet weak var pickerview: UIPickerView!
    @IBOutlet weak var txtContainer: UIView!
    @IBOutlet weak var photoCont: UIView!
    @IBOutlet weak var videoCont: UIView!
    @IBOutlet weak var heartrateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    var photoSegmentController: PhotoSegmentViewController?
    var videoSegmentController: VideoSegmentViewController?
    var textSegmentController: TextSegmentViewController?
    
    var heartPicker = true
    var selectedAfterDecimal: Int = 0
    var selectedBeforeDecimal: Int = 0
    var selectedScale: String = "F"
    var selectedBPM: Int = 0
    var selectedRatingImage: UIImageView?
    var selectedRatingLabel: UILabel?
    
    var scale: [String] = ["F", "C"]
    var beforeDecimal: [Int] = []
    let afterDecimal: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var bpm: [Int] = []
    
    var delegate: LogCreationViewDelegate?
    var hasPresetLog = false
    var presetLog: HealthLog?
    var presetImage: UIImage?
    var presetVideo: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateRange(scale: selectedScale)
        
        for i in 50...190 {
            bpm.append(i)
        }
        
        txtContainer.isHidden = false
        photoCont.isHidden = true
        videoCont.isHidden = true
        pickerStack.isHidden = true
        
        pickerview.delegate = self
        pickerview.dataSource = self
        
        temperatureLabel.text = "--.- °\(selectedScale)"
        heartrateLabel.text = "--- BPM"
        temperatureLabel.textColor = .gray
        heartrateLabel.textColor = .gray
        
        for stack in imageStack.arrangedSubviews {
            let rating = stack as? UIStackView
            rating?.arrangedSubviews[0].tintColor = .black
        }
        
        if hasPresetLog {
            self.populateFields()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateFields() {
        if let log = presetLog {
            if log.hasText == 1 {
                textSegmentController?.setText(log.text)
            }
            if log.hasPicture == 1 {
                photoSegmentController?.setImage(image: presetImage)
            }
            if log.hasVideo == 1 {
                videoSegmentController?.video = presetVideo
            }
        }
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
        if selectedRatingLabel != nil {
            selectedRatingLabel?.textColor = .black
            selectedRatingImage?.tintColor = .black
        }
        if let selected = sender.view as? UIStackView {
            if let image = selected.arrangedSubviews[0] as? UIImageView {
                selected.arrangedSubviews[0].tintColor = self.view.tintColor
                selectedRatingImage = image
            }
            if let text = selected.arrangedSubviews[1] as? UILabel {
                text.textColor = self.view.tintColor
                selectedRatingLabel = text
            }
        }
    }
    
    @IBAction func temperaturePressed(_ sender: UITapGestureRecognizer) {
        heartPicker = false
        pickerview.reloadAllComponents()
        if pickerStack.isHidden {
            pickerStack.alpha = 0.0
            pickerStack.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.pickerStack.alpha = 1.0
            })
        }
        
    }
    
    @IBAction func heartratePressed ( _ sender: UITapGestureRecognizer) {
        heartPicker = true
        pickerview.reloadAllComponents()
        if pickerStack.isHidden {
            pickerStack.isHidden = false
            pickerStack.alpha = 0.0
            UIView.animate(withDuration: 0.2, animations: {
                self.pickerStack.alpha = 1.0
            })
        }
    }
    
    @IBAction func dismissPickerview(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerStack.alpha = 0.0
            })
        pickerStack.isHidden = true
    }
    
    @IBAction func saveLogPressed(_ sender: UIBarButtonItem) {
        let validation = validateLog()
        if validation.isEmpty || hasPresetLog {
            let hasText = (textSegmentController?.hasBeenEdited)! ? 1 : 0
            let hasVideo = videoSegmentController?.video != nil ? 1 : 0
            let hasPicture = photoSegmentController?.image != nil ? 1 : 0
            if hasPresetLog {
                self.presetLog?.hasVideo = hasVideo
                self.presetLog?.hasPicture = hasPicture
                delegate?.saveLog(log: presetLog!, picture: photoSegmentController?.image, video: videoSegmentController?.video)
            } else {
                let log = HealthLog.init(key: nil, date: Date(), temperature: temperatureLabel.text!,
                                         heartrate: heartrateLabel.text!, moodrating: (selectedRatingLabel?.text)!,
                                         hasText: hasText, text: textSegmentController?.getText(),
                                         hasPicture: hasPicture, pictureURL: "", hasVideo: hasVideo, videoURL: "")
                delegate?.saveLog(log: log, picture: photoSegmentController?.image, video: videoSegmentController?.video)
            }
            self.navigationController?.popViewController(animated: true)
        } else {
            reportError(msg: validation[0])
        }
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
    
    func validateLog() -> [String] {
        var errors = [String]()
        if selectedBeforeDecimal == 0 {
            errors.append("Temperature has not been selected")
        }
        if selectedRatingLabel == nil {
            errors.append("Mood rating is not selected")
        }
        if selectedBPM == 0 {
            errors.append("Heart rate has not been selected")
        }
        return errors
    }
    
    @IBAction func addMediaToLog(segue: UIStoryboardSegue) {
        if let source = segue.source as? PreviewViewController {
            if source.videoPreview {
                videoSegmentController?.video = source.videoURL
            } else {
                photoSegmentController?.setImage(image: source.image)
            }
        }
    }
    
    func startCamera(_ sender: UIViewController) {
        let controller = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "cameraview") as? CameraViewController
        if let _ = sender as? PhotoSegmentViewController {
            controller?.videoCap = false
        } else if let _ = sender as? VideoSegmentViewController {
            controller?.videoCap = true
        }
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    func reportError(msg: String) {
        let alert = UIAlertController(title: "Log not created", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedPhotoSegue" {
            photoSegmentController = segue.destination as? PhotoSegmentViewController
        } else if segue.identifier == "embeddedVideoSegue" {
            videoSegmentController = segue.destination as? VideoSegmentViewController
            if hasPresetLog {
                videoSegmentController?.video = presetVideo
            }
        } else if segue.identifier == "embeddedTextSegue" {
            textSegmentController = segue.destination as? TextSegmentViewController
        }
    }
}

extension LogCreationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if heartPicker {
            return 1
        } else {
            return 4
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if heartPicker {
            return bpm.count
        } else {
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
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if heartPicker {
            selectedBPM = bpm[row]
            heartrateLabel.text = "\(selectedBPM) BPM"
            heartrateLabel.textColor = .black
        } else {
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
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if heartPicker {
            return String(bpm[row])
        } else {
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
}
