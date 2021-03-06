//
//  LoginViewController.swift
//  Twitter Clone
//
//  Created by Bryce Sulin on 3/18/17.
//  Copyright © 2017 BryceSulin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
            
            if(error == nil)
            {
                self.rootRef.child("user_profiles").child((user?.uid)!).child("handle").observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
                    
                    if(!snapshot.exists())
                    {
                        //user does not have a handle
                        //send the user to the handleView
                        
                        self.performSegue(withIdentifier: "HandleViewSegue", sender: nil)
                    }
                    else
                    {
                        self.performSegue(withIdentifier: "HomeViewSegue", sender: nil)
                    }
                    
                })
            }
            else
            {
                self.errorMessage.text = error?.localizedDescription
            }
            
        })
    }
}
