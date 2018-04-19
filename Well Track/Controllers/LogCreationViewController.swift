//
//  LogCreationViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Implementation by Daniel Cummings, 2/27/18
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


/// Delegate for Well Track log creation.
protocol LogCreationViewDelegate {
    func saveLog(log: HealthLog, latitude: Float?, longitude: Float?)
}


/// Controller for the log creation screen which displays components of log creation to the user. Users can include temperature, heart rate, and mood as necessary minimum information. In addition to the necessary information, users can choose to include additional text and video/pictures to the log.
class LogCreationViewController: UIViewController {
    
    /// Stack view UI picker and navbar.
    @IBOutlet weak var pickerStack: UIStackView!
    /// Stack view containing sub-stackviews for each mood object.
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
    private let thermData = ThermoDataProvider()
    private var thermoTemp: Double?
    
    var heartPicker = true
    var selectedAfterDecimal: Int = 0
    var selectedBeforeDecimal: Int = 0
    var selectedScale: String = "F"
    var selectedBPM: Int = 0
    var selectedRatingImage: UIImageView?
    var selectedRatingLabel: UILabel?
    var saved = false
    
    var scale: [String] = ["F", "C"]
    var beforeDecimal: [Int] = []
    let afterDecimal: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    var bpm: [Int] = []
    
    var delegate: LogCreationViewDelegate?
    var locationManager: CLLocationManager?
    var hasPresetLog = false
    var log: HealthLog!
    var settings: Settings?
    var uid: String!
    var currentLocation: CLLocation?
    
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
        
        // Set delegate and datasource of UIPickerview.
        pickerview.delegate = self
        pickerview.dataSource = self
        
        temperatureLabel.text = "--.- °\(selectedScale)"
        heartrateLabel.text = "--- BPM"
        temperatureLabel.textColor = .gray
        heartrateLabel.textColor = .gray
        
        // Sets all of the tint colors for images in mood stack.
        for stack in imageStack.arrangedSubviews {
            let rating = stack as? UIStackView
            rating?.arrangedSubviews[0].tintColor = .black
        }
       
        uid = Auth.auth().currentUser?.uid
        if hasPresetLog {
            self.populateFields()
        } else {
            let key = Database.database().reference(withPath: uid!).childByAutoId().key
            log = HealthLog()
            log.date = Date()
            log.key = key
        }
        
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestAlwaysAuthorization()
        locationManager!.requestLocation()
        
        videoSegmentController?.startFirebase(uid: uid, log: log)
        photoSegmentController?.startFirebase(uid: uid, log: log)
        if let settings = settings, settings.nokiaAccount == 1 {
            self.checkIntervalTemp()
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            if !saved {
                Database.database().reference(withPath: "\(uid)/Logs/\(log.key!)").removeValue()
                if let data = videoSegmentController!.data {
                    for item in data {
                        videoSegmentController?.removeSelectedVideo(item: item)
                    }
                }
                if let data = photoSegmentController!.data {
                    for item in data {
                        photoSegmentController?.removeSelectedPicture(item: item)
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Helper method to populate views with data passed to the controller.
    func populateFields() {
        if let presetLog = log {
            if presetLog.hasText == 1 {
                textSegmentController?.setText(log.text)
            }
            var loc = 0
            switch log.moodrating {
            case "Fine":
                loc = 2
                break
            case "Good":
                loc = 3
                break
            case "Bad":
                loc = 1
                break
            case "Great":
                loc = 4
                break
            case "Terrible":
                loc = 0
                break
            default:
                break
            }
            // Set the selected mood image color.
            let temp = imageStack.arrangedSubviews[loc] as? UIStackView
            selectedRatingLabel = temp?.arrangedSubviews[1] as? UILabel
            selectedRatingImage = temp?.arrangedSubviews[0] as? UIImageView
            selectedRatingImage?.tintColor = self.view.tintColor
            selectedRatingLabel?.textColor = self.view.tintColor
            
            self.temperatureLabel.text = presetLog.temperature
            self.heartrateLabel.text = presetLog.heartrate
        }
    }
    
    
    /// Generates the input scale for the UI picker view.
    ///
    /// - Parameter scale: Indicates which scale needs to be generated.
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
    
    /// Fires when a tap gesture recognizer on the mood image stack is fired.
    ///
    /// - Parameter sender: Tap gesture recognizer which was activated.
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
                log.moodrating = text.text!
            }
        }
    }
    
    /// Fires when the temperature stack view is selected by the user.
    ///
    /// - Parameter sender: Tap gesture recognizer which was activated by the user.
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
    
    /// Fires when the heart rate stack is selected by the user.
    ///
    /// - Parameter sender: Tap gesture recognizer that was selected by the user.
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
    
    
    /// Fires when the user selects the "done" button attached to the UIPickerView's navbar.
    ///
    /// - Parameter sender: The button that activated the method.
    @IBAction func dismissPickerview(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.pickerStack.alpha = 0.0
            })
        pickerStack.isHidden = true
    }
    
    /// Fires when the user attempts to save the log. The function checks whether the minimal requirements for a Well Track log has been met. If no errors are found the function creates a new health log and calls the saveLog method in the delegate.
    ///
    /// - Parameter sender: The button item attached to this function.
    @IBAction func saveLogPressed(_ sender: UIBarButtonItem) {
        let validation = validateLog()
        if validation.isEmpty || hasPresetLog {
            if (textSegmentController?.hasBeenEdited)! {
                self.log?.text = textSegmentController?.getText()
                self.log?.hasText = 1
            }
            self.saved = true
            log.hasVideo = videoSegmentController?.data != nil ? 1 : 0
            log.hasPicture = photoSegmentController?.data != nil ? 1 : 0
            if let location = self.currentLocation {
                log.hasLocation = 1
                log.latitude = Float(location.coordinate.latitude.magnitude)
                log.longitude = Float(location.coordinate.longitude.magnitude)
            } else {
                log.hasLocation = 0
                log.latitude = 0.0
                log.longitude = 0.0
            }
            delegate?.saveLog(log: log, latitude: log.latitude, longitude: log.longitude)
            self.navigationController?.popViewController(animated: true)
        } else {
            reportError(msg: validation[0])
        }
    }
    
    /// Action function for the segmented view controller which shows and hides views based on the user selected option.
    ///
    /// - Parameter sender: the Segmented controller attached to this function.
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
            // Required break.
            break
        }
    }
    
    /// Attempts to validate the information provided to this log controller by the user.
    ///
    /// - Returns: Error messages to indicate problems with log validation, may be empty.
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
    
    /// Unwind segue definition for adding media to the appropriate view controller.
    ///
    /// - Parameter segue: The segue containing information about the unwind being performed.
    @IBAction func addMediaToLog(segue: UIStoryboardSegue) {
        if let source = segue.source as? PreviewViewController {
            if source.videoPreview {
                videoSegmentController?.addVideoToFirebase(source.videoURL!)
            } else {
                photoSegmentController?.addPhotoToFirebase(source.image!)
            }
        }
    }
    
    
    /// Function to obtain an instance of CameraViewController and push it onto the view stack for this navigation controller.
    ///
    /// - Parameter sender: View controller sending the request to start the camera.
    func startCamera(_ sender: UIViewController) {
        let controller = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "cameraview") as? CameraViewController
        if let _ = sender as? PhotoSegmentViewController {
            controller?.videoCap = false
        } else if let _ = sender as? VideoSegmentViewController {
            controller?.videoCap = true
        }
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    
    /// Helper function to fire a UIAlertController to display the messaged passed to the function.
    ///
    /// - Parameter msg: Message to be displayed to the user.
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
        } else if segue.identifier == "embeddedTextSegue" {
            textSegmentController = segue.destination as? TextSegmentViewController
        }
    }
}

extension LogCreationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        guard let location = locations.last else {
            return
        }
        self.currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
            log.heartrate = "\(selectedBPM) BPM"
            heartrateLabel.text = log.heartrate
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
            log.temperature = "\(selectedBeforeDecimal).\(selectedAfterDecimal) °\(selectedScale)"
            self.temperatureLabel.text = log.temperature
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
    
    // added for Thermo, unsure if correct way to add to log view
    func checkIntervalTemp() {
        self.thermData.makeRequest(userID: (settings?.userID)!, authToken: (settings?.authToken)!, authSec: (settings?.authSec)!, handler: { (temp) in
            DispatchQueue.main.async {
                self.temperatureLabel.text = "\(temp) °F"
            }
        })
    }
}
