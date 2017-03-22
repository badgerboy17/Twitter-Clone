//
//  HomeViewTableViewCell.swift
//  Twitter Clone
//
//  Created by Bryce Sulin on 3/19/17.
//  Copyright © 2017 BryceSulin. All rights reserved.
//

import UIKit

public class HomeViewTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var tweet: UITextView!
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open func configure(profilePic:String?,name:String,handle:String,tweet:String)
    {
        self.tweet.text = tweet
        self.handle.text = "@" + handle
        self.name.text = name
        
        
        
        if((profilePic) != nil)
        {
            let imageData = try? Data(contentsOf: URL(string:profilePic!)!)
            self.profilePic.image = UIImage(data:imageData! as Data)
        }
        else
        {
            self.profilePic.image = UIImage(named: "twitter")
        }
        
    }
}
