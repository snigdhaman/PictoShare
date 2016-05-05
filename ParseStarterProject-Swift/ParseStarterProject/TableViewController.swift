//
//  TableViewController.swift
//  PictoShare
//
//  Created by Chatterjee, Snigdhaman on 26/01/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var username = [String]()
    var userId = [String]()
    var isFollowing = Dictionary <String, Bool> ()
    var refresher: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        pullToRefresh()
        refresh()
    }

    @IBAction func logout(sender: AnyObject) {
        animateSpinner()
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if PFUser.currentUser()?.objectId == nil {
                        self.performSegueWithIdentifier("logout", sender: self)
                    }
                })
            } else {
                if let errorString = error!.userInfo["error"] as? String {
                    self.displayErrorAlert("Oops!!", message: errorString)
                }
            }
        }
    }
    
    func isFollowing(userId: String) {
        let predicate = NSPredicate(format: "following = %@ AND follower = %@", userId, PFUser.currentUser()!.objectId!)
        let query = PFQuery(className: "Followers", predicate: predicate)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                if objects?.count > 0 {
                    self.isFollowing[userId] = true
                    self.tableView.reloadData()
                } else {
                    self.isFollowing[userId] = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func pullToRefresh() {
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
    }
    
    func refresh() {
        username.removeAll()
        userId.removeAll()
        isFollowing.removeAll()
        animateSpinner()
        let query = PFUser.query()
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil {
                if let userList = objects {
                    for object in userList {
                        if let user = object as? PFUser {
                            if user.objectId != PFUser.currentUser()?.objectId {
                                self.username.append(user.username!)
                                self.userId.append(user.objectId!)
                                self.isFollowing(user.objectId!)
                            }
                        }
                    }
                }
            } else {
                if let errorString = error!.userInfo["error"] as? String {
                    self.displayErrorAlert("Oops!!", message: errorString)
                }
            }
            self.refresher.endRefreshing()
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
        })

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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userId.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = username[indexPath.row]
        if isFollowing[userId[indexPath.row]] == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    
    @available(iOS 8.0, *)
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if isFollowing[userId[indexPath.row]] == false {
            let followAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Follow") { (action, indexPath) -> Void in
                let following = PFObject(className: "Followers")
                following["following"] = self.userId[indexPath.row]
                following["follower"] = PFUser.currentUser()?.objectId
                following.saveInBackground()
                self.isFollowing[self.userId[indexPath.row]] = true
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                tableView.reloadData()
            }
            return [followAction]
        } else {
            let unfollowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Unfollow") { (action, indexPath) -> Void in
                let predicate = NSPredicate(format: "following = %@ AND follower = %@", self.userId[indexPath.row], PFUser.currentUser()!.objectId!)
                let query = PFQuery(className: "Followers", predicate: predicate)
                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if error == nil {
                        if objects?.count > 0 {
                            for object in objects! {
                                object.deleteInBackground()
                            }
                        }
                    }
                    cell.accessoryType = UITableViewCellAccessoryType.None
                    self.isFollowing[self.userId[indexPath.row]] = false
                })
                tableView.reloadData()
            }
            return [unfollowAction]
        }
    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
