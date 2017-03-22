//
//  ViewController.swift
//  Twitter Clone
//
//  Created by Bryce Sulin on 3/18/17.
//  Copyright © 2017 BryceSulin. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRAuth.auth()?.addStateDidChangeListener ({ (auth, user) in
            
            if let currentUser = user
            {
                print("user is signed in")
                
                // Send the user to HomeViewController
                let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main",bundle:nil)
                
                let homeViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarControllerView")
                
                // Send the user to homescreen
                self.present(homeViewController, animated: true, completion: nil)
            }
            
            
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
