//
//  HomeViewController.swift
//  Twitter Clone
//
//  Created by Bryce Sulin on 3/19/17.
//  Copyright © 2017 BryceSulin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser: AnyObject?
    var loggedInUserData: NSDictionary?
    

    @IBOutlet weak var aivLoading: UIActivityIndicatorView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var defaultImageViewHeightConstraint:CGFloat = 77.0
    
    var tweets = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        // Get the logged in user's details
        self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEvent(of: .value) { (snapshot:FIRDataSnapshot) in
            
            // Store the logged in user's details
            self.loggedInUserData = snapshot.value as? NSDictionary
            
            // Get all the tweets that are made by the user
            self.databaseRef.child("tweets").child(self.loggedInUser!.uid).observe(.childAdded, with: { (snapshot:FIRDataSnapshot) in
                
                
                self.tweets.append(snapshot.value as! NSDictionary)
                
                self.homeTableView.insertRows(at: [IndexPath(row:0,section:0)], with: UITableViewRowAnimation.automatic)
                                
                self.aivLoading.stopAnimating()
                
            }){(error) in
                print(error.localizedDescription)
            }
            
        }
        
        self.homeTableView.rowHeight = UITableViewAutomaticDimension
        self.homeTableView.estimatedRowHeight = 140
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: HomeViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeViewTableViewCell", for: indexPath as IndexPath) as!
            HomeViewTableViewCell
        
        let tweet = tweets[(self.tweets.count-1) - (indexPath.row)]["text"] as! String
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapMediaInTweet(_:)))
        
        cell.tweetImage.addGestureRecognizer(imageTap)
        
        if(tweets[(self.tweets.count-1) - (indexPath.row)]["picture"] != nil)
        {
            cell.tweetImage.isHidden = false
            cell.imageViewHeightConstraint.constant = defaultImageViewHeightConstraint
            
            let picture = tweets[(self.tweets.count-1) - (indexPath.row)]["picture"] as! String
            let url = URL(string:picture)
            cell.tweetImage.layer.cornerRadius = 10
            cell.tweetImage.layer.borderWidth = 3
            cell.tweetImage.layer.borderColor = UIColor.white.cgColor
            
            cell.tweetImage!.sd_setImage(with: url, placeholderImage: UIImage(named:"twitter")!)
        }
        else
        {
            cell.tweetImage.isHidden = true
            cell.imageViewHeightConstraint.constant = 0
        }
        
        cell.configure(profilePic: nil, name: self.loggedInUserData!["name"] as! String,handle:self.loggedInUserData!["handle"] as! String,tweet:tweet)
        
        return cell
    }
    
    func didTapMediaInTweet(_ sender:UITapGestureRecognizer)
    {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        
        newImageView.frame = self.view.frame
        
        newImageView.backgroundColor = UIColor.black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
        
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullScreenImage(sender:UITapGestureRecognizer)
    {
        sender.view?.removeFromSuperview()
    }

}
