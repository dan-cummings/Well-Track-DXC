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

class RegistrationViewController: UIViewController{
    
    @IBOutlet weak var confirmPassField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    var handle: NSObjectProtocol?
    var delegate: RegistrationDelegate?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in })
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        let errors: [String] = self.validateFields()
        if errors.isEmpty {
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if let _ = user {
                    self.dismiss(animated: true, completion: nil)
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
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reportError(msg: String) {
        let alert = UIAlertController(title: "Registration Failed", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
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
