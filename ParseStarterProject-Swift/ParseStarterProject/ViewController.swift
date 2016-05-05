/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var emailID: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var checkPassword: UITextField!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func signUp(sender: AnyObject) {
        if username.text!.isEmpty || password.text!.isEmpty || emailID.text!.isEmpty || checkPassword.text!.isEmpty {
            self.displayErrorAlert("Error in form", message: "Please ensure all details are entered")
        } else if password.text != checkPassword.text {
            self.displayErrorAlert("Error in form", message: "Please ensure both passwords are matching")
        } else {
            animateSpinner()
            signUpNewUser()
        }
    }
    
    func signUpNewUser() {
        let user = PFUser()
        user.username = username.text
        user.password = password.text
        user.email = emailID.text
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if error == nil {
                self.performSegueWithIdentifier("signUp", sender: self)
            } else {
                if let errorString = error!.userInfo["error"] as? String {
                    self.displayErrorAlert("Error in sign up", message: errorString)
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if PFUser.currentUser()?.objectId != nil {
                self.performSegueWithIdentifier("signUp", sender: self)
            }
        }
    }
    
    func displayErrorAlert(title: String, message: String) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func animateSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
}
