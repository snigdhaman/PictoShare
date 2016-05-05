//
//  LoginViewController.swift
//  PictoShare
//
//  Created by Chatterjee, Snigdhaman on 26/01/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: ViewController {

    @IBOutlet weak var loginUsernameField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func goButton(sender: AnyObject) {
        if loginUsernameField.text!.isEmpty || loginPasswordField.text!.isEmpty {
            self.displayErrorAlert("Error in form", message: "Please ensure both username and password are entered")
        } else {
            animateSpinner()
            loginUser()
        }
    }
    
    func loginUser() {
        PFUser.logInWithUsernameInBackground(loginUsernameField.text!, password: loginPasswordField.text!) { (user, error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if user != nil {
                self.performSegueWithIdentifier("login", sender: self)
            } else {
                if let errorString = error!.userInfo["error"] as? String {
                    self.displayErrorAlert("Error in login", message: errorString)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
