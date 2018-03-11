//
//  LogInformationViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/18/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit

/// View controller to display health log information with more detail. Contains views for video and photos along with extra text information.
class LogInformationViewController: UIViewController {
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var log: HealthLog?
    var textSegment: TextSegmentViewController?
    var photoSegment: PhotoSegmentViewController?
    var videoSegment: VideoSegmentViewController?
    var delegate: LogCreationViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let log = self.log {
            heartRateLabel.text = log.heartrate
            moodLabel.text = log.moodrating
            temperatureLabel.text = log.temperature
            switch log.moodrating {
            case "Fine":
                moodImageView.image = UIImage(named: "Fair")
                break
            case "Good":
                moodImageView.image = UIImage(named: "Good")
                break
            case "Great":
                moodImageView.image = UIImage(named: "Great")
                break
            case "Bad":
                moodImageView.image = UIImage(named: "Bad")
                break
            case "Terrible":
                moodImageView.image = UIImage(named: "Terrible")
                break
            default:
                break
            }
            moodImageView.tintColor = .black
            dateLabel.text = log.date?.short
        }
        textView.isHidden = false
        photoView.isHidden = true
        videoView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Instantiates log creation view and passes a health log to it which indicates edits will be made on the provided log.
    ///
    /// - Parameter sender: The button sending the action.
    @IBAction func editLogPressed(_ sender: Any) {
        let editView = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LogCreation") as! LogCreationViewController
        editView.delegate = self
        editView.hasPresetLog = true
        editView.presetImage = photoSegment?.image
        editView.presetVideo = videoSegment?.video
        editView.presetLog = log
        self.navigationController?.pushViewController(editView, animated: true)
    }
    
    @IBAction func selectorChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            textView.isHidden = false
            photoView.isHidden = true
            videoView.isHidden = true
            break
        case 1:
            textView.isHidden = true
            photoView.isHidden = false
            videoView.isHidden = true
            break
        case 2:
            textView.isHidden = true
            photoView.isHidden = true
            videoView.isHidden = false
            break
        default:
            break
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoTextEmbeddedSegue" {
            textSegment = segue.destination as? TextSegmentViewController
            textSegment?.infoCaller = true
            textSegment?.log = self.log
        } else if segue.identifier == "infoPhotoEmbeddedSegue" {
            photoSegment = segue.destination as? PhotoSegmentViewController
            photoSegment?.infoView = true
            photoSegment?.log = self.log
        } else if segue.identifier == "infoVideoEmbeddedSegue" {
            videoSegment = segue.destination as? VideoSegmentViewController
            videoSegment?.infoView = true
            videoSegment?.log = self.log
        }
    }

}

extension LogInformationViewController: LogCreationViewDelegate {
    func saveLog(log: HealthLog, picture: UIImage?, video: URL?, latitude: Float?, longitude: Float?) {
        //Passes delegate call.
        delegate?.saveLog(log: log, picture: picture, video: video, latitude: latitude, longitude: longitude)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
