//
//  RegistrationViewController.swift
//  Well Track
//
//  Created by Daniel Cummings on 2/3/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol RegistrationDelegate {
    func populateFields();
}

/// View controller for the registration view.
class RegistrationViewController: UIViewController{
    
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    var delegate: RegistrationDelegate?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// Action function to attempt to register the new user using the fields.
    ///
    /// - Parameter sender: Reference to the register button.
    @IBAction func registerPressed(_ sender: Any) {
        let errors: [String] = self.validateFields()
        if errors.isEmpty {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if let _ = user {
                    self.performSegue(withIdentifier: "setDefaultSettings", sender: self)
                } else {
                    self.reportError(msg: (error?.localizedDescription)!)
                }
            })
        } else {
            self.reportError(msg: errors[0])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Function to display error message that is passed to the function.
    ///
    /// - Parameter msg: Error message to be displayed.
    func reportError(msg: String) {
        let alert = UIAlertController(title: "Registration Failed", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Function to validate the registration fields to ensure proper creation of firebase user.
    ///
    /// - Returns: A list of errors for the field.
    func validateFields() -> [String] {
         var values: [String] = []
        guard let email = emailField.text else {
            values.append("Please Enter a Valid Email")
            return values
        }
        guard let password = passwordField.text else {
            values.append("Password Field is empty")
            return values
        }
        guard let confPass = confirmPassField.text else {
            values.append("Please Confirm Password")
            return values
        }
        if !validateEmail(candidate: email) {
            values.append("Invalid Email")
        }
        if confPass != password {
            values.append("Passwords do not match")
        }
        return values
    }
    
    /// Validates the email field to return true if it matches the email regex.
    ///
    /// - Parameter candidate: The email which needs validation.
    /// - Returns: True if email is valid, otherwise false.
    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
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
