//
//  LandingPageViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth

/// Controller for the sign in screen.
class LandingPageViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var memberLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = BACKGROUND_COLOR
        passwordField.textColor = TEXT_DEFAULT_COLOR
        emailField.textColor = TEXT_DEFAULT_COLOR
        signinButton.titleLabel?.textColor = BACKGROUND_COLOR
        signinButton.backgroundColor = TEXT_DEFAULT_COLOR
        registerButton.titleLabel?.textColor = BACKGROUND_COLOR
        registerButton.backgroundColor = TEXT_DEFAULT_COLOR
        memberLabel.textColor = TEXT_DEFAULT_COLOR
        titleLabel.textColor = TEXT_DEFAULT_COLOR
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /// Attempts to log the user in with the input information.
    ///
    /// - Parameter sender: The button connected to this action.
    @IBAction func signinPressed(_ sender: Any) {
        if let email = emailField.text {
            if let password = passwordField.text {
                Auth.auth().signIn(withEmail: email, password: password, completion: {user, error in
                    if let _ = user {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.reportError(msg: (error?.localizedDescription)!)
                    }
                })
            }
        }
    }
    
    func reportError(msg: String) {
        let alert = UIAlertController(title: "Login Failed", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
