//
//  NewTweetViewController.swift
//  Twitter Clone
//
//  Created by Bryce Sulin on 3/19/17.
//  Copyright © 2017 BryceSulin. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class NewTweetViewController: UIViewController, UITextViewDelegate,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newTweetTextView: UITextView!
    @IBOutlet weak var newTweetToolbar: UIToolbar!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintInitialValue:CGFloat?
    
    // Create a reference to the database
    var databaseRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newTweetToolbar.isHidden = true
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
        
        newTweetTextView.textContainerInset = UIEdgeInsetsMake(30, 20, 20, 20)
        newTweetTextView.text = "What's Happening?"
        newTweetTextView.textColor = UIColor.lightGray
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        enableKeyboardHideOnTap()
        
        self.toolbarBottomConstraintInitialValue = toolbarBottomConstraint.constant
    }
    
    fileprivate func enableKeyboardHideOnTap()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector
            (NewTweetViewController.hideKeyboard))
        
        self.view.addGestureRecognizer(tap)
    }
    
    func keyboardWillShow(_ notification: NSNotification)
    {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height
            self.newTweetToolbar.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(_ notfication: NSNotification)
    {
        let duration = notfication.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            
            self.toolbarBottomConstraint.constant = self.toolbarBottomConstraintInitialValue!
            
            self.newTweetToolbar.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
    
    func hideKeyboard()
    {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(newTweetTextView.textColor == UIColor.lightGray)
        {
            newTweetTextView.text = ""
            newTweetTextView.textColor = UIColor.black
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    @IBAction func didTapTweet(_ sender: Any) {
        var imagesArray = [AnyObject]()
        
        self.newTweetTextView.attributedText.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, self.newTweetTextView.text.characters.count), options: []) { (value, range, true) in
            
            if(value is NSTextAttachment)
            {
                let attachment = value as! NSTextAttachment
                var image : UIImage? = nil
                
                if(attachment.image !== nil)
                {
                    image = attachment.image!
                    imagesArray.append(image!)
                }
                else
                {
                    print("No image found")
                }
            }
            
        }
        
        let tweetLength = newTweetTextView.text.characters.count
        let numImages = imagesArray.count
        
        let key = self.databaseRef.child("tweets").childByAutoId().key
        let storageRef = FIRStorage.storage().reference()
        let pictureStorageRef = storageRef.child("user_profiles/\(self.loggedInUser!.uid)/media/\(key)")
            
        if(tweetLength>0 && numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)

            let uploadTask = pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = ["/tweets/\(self.loggedInUser!.uid!)/\(key)/text":self.newTweetTextView.text,"/tweets/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(NSDate().timeIntervalSince1970)",
                    "/tweets/\(self.loggedInUser!.uid!)/\(key)/picture":downloadUrl!.absoluteString] as [String : Any]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                }
            }
            
            dismiss(animated: true, completion: nil)
            
        }
        else if(tweetLength>0)
        {
            let childUpdates = ["/tweets/\(self.loggedInUser!.uid!)/\(key)/text":newTweetTextView.text,"/tweets/\(self.loggedInUser!.uid!)/\(key)/timestamp":"\(NSDate().timeIntervalSince1970)"] as [String : Any]
            
            self.databaseRef.updateChildValues(childUpdates)
            
            dismiss(animated: true, completion: nil)
        }
        else if(numImages>0)
        {
            let lowResImageData = UIImageJPEGRepresentation(imagesArray[0] as! UIImage, 0.50)

            let uploadTask = pictureStorageRef.put(lowResImageData!,metadata: nil)
            {metadata,error in
                
                if(error == nil)
                {
                    let downloadUrl = metadata!.downloadURL()
                    
                    let childUpdates = ["/tweets/\(self.loggedInUser!.uid)/\(key)/timestamp":"\(NSDate().timeIntervalSince1970)",
                        "/tweets/\(self.loggedInUser!.uid)/\(key)/picture":downloadUrl!.absoluteString]
                    
                    self.databaseRef.updateChildValues(childUpdates)
                    
                }
                else
                {
                    print(error?.localizedDescription)
                }
            }
            
            dismiss(animated: true, completion: nil)
        }
        
        
    }
    @IBAction func selectImageFromPhotos(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        var attributedString = NSMutableAttributedString()
        
        if(self.newTweetTextView.text.characters.count>0)
        {
            attributedString = NSMutableAttributedString(string:self.newTweetTextView.text)
        }
        else
        {
            attributedString = NSMutableAttributedString(string:"What's Happening?\n")
        }
        
        let textAttachment = NSTextAttachment()
        
        textAttachment.image = image
        let oldWith:CGFloat = textAttachment.image!.size.width
        
        let scaleFactor:CGFloat = oldWith/(newTweetTextView.frame.size.width-50)
        
        textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        
        attributedString.append(attrStringWithImage)
        
        newTweetTextView.attributedText = attributedString
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
