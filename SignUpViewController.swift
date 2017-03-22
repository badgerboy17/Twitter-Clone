//
//  SignUpViewController.swift
//  Twitter Clone
//
//  Created by Bryce Sulin on 3/18/17.
//  Copyright © 2017 BryceSulin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signUp: UIBarButtonItem!
    @IBOutlet weak var errorMessage: UILabel!
    
    var databaseRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUp.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSignup(_ sender: Any) {
        // Disable signup button to prevent from clicking twice
        signUp.isEnabled = false
        
        FIRAuth.auth()?.createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
            
            if(error != nil)
            {
                self.errorMessage.text = error?.localizedDescription
            }
            else
            {
                self.errorMessage.text = "Registered Succesfully"
                
                FIRAuth.auth()?.signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                    
                    if(error == nil)
                    {
                        self.databaseRef.child("user_profiles").child(user!.uid).child("email").setValue(self.email.text!)
                        
                        self.performSegue(withIdentifier: "HandleViewSegue", sender: nil)
                    }
                })
            }
        })
        
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        if(email.text!.characters.count>0 && password.text!.characters.count>0)
        {
            signUp.isEnabled = true
        }
        else
        {
            signUp.isEnabled = false
        }
    }
}
