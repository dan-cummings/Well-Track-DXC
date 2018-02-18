//
//  LandingPageViewController.swift
//  Well Track
//
//  Created by Morgan Oneka on 1/31/18.
//  Copyright © 2018 Team DXC. All rights reserved.
//

import UIKit
import FirebaseAuth

class LandingPageViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var handle: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
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
