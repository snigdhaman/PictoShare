//
//  PostImageViewController.swift
//  PictoShare
//
//  Created by Chatterjee, Snigdhaman on 26/01/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var imageDescription: UITextField!
    @IBOutlet weak var postButton: UIButton!
    
    var status: Bool = false
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func chooseImage(sender: AnyObject) {
        status = true
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "Choose image source", message: "Select an image from your camera or photo roll", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Photos", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.selectImage(false)
            }))
            alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.selectImage(true)
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func selectImage(selectFromCamera: Bool) {
        let image = UIImagePickerController()
        image.delegate = self
        if selectFromCamera == true {
            image.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        imageToPost.image = image
    }

    @IBAction func postImage(sender: AnyObject) {
        if status == true {
            animateSpinner()
            let image = PFObject(className: "ImagePost")
            image["userID"] = PFUser.currentUser()?.objectId
            var message: String = "Default"
            if !imageDescription.text!.isEmpty {
                message = imageDescription.text!
            }
            image["message"] = message
            let compressionRatio: CGFloat = 1.0
            var imageData = UIImageJPEGRepresentation(imageToPost.image!, compressionRatio)
            let newCompressionRatio: CGFloat = getCompressionRatio(imageData!, compressionRatio: compressionRatio)
            imageData = UIImageJPEGRepresentation(imageToPost.image!, newCompressionRatio)
            if imageData?.length > 10485760 {
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if #available(iOS 8.0, *) {
                    let alert = UIAlertController(title: "Image cannot be uploaded", message: "My compression algorithm isn't smart enough to handle such a hot image!!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                let imageFile = PFFile(name: message, data: imageData!)
                image["imageFile"] = imageFile
                image.saveInBackgroundWithBlock { (success, error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if error == nil {
                        if #available(iOS 8.0, *) {
                            let alert = UIAlertController(title: "Image upload successful", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                alert.dismissViewControllerAnimated(true, completion: nil)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        self.imageToPost.image = UIImage(named: "placeholder.png")
                        self.imageDescription.text = ""
                        self.status = false
                    } else {
                        if #available(iOS 8.0, *) {
                            if let errorMessage = error?.userInfo["error"] as? String {
                                let alert = UIAlertController(title: "Error in image upload", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                    alert.dismissViewControllerAnimated(true, completion: nil)
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        } else {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Please select an image", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func animateSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.center = self.view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func getCompressionRatio(imageData: NSData, compressionRatio: CGFloat) -> CGFloat {
        let imageSize: Int = imageData.length
        if imageSize > 10485760 && compressionRatio >= 0.05 {
            getCompressionRatio(UIImageJPEGRepresentation(imageToPost.image!, compressionRatio - 0.05)!, compressionRatio: compressionRatio - 0.05)
        }
        return compressionRatio
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
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
