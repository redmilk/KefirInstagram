//
//  SignUpViewController.swift
//  MonsterFeed
//
//  Created by Artem on 1/13/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var confirmPwd: UITextField!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var selectPicture: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    //reference to user storage
    var userStorage: FIRStorageReference!
    //reference to database
    var dataBase: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        self.setupView()
        
        //reference to my storage
        let storage = FIRStorage.storage().reference(forURL: "gs://test-13497.appspot.com")
        self.userStorage = storage.child("users")
        //reference to the database
        self.dataBase = FIRDatabase.database().reference()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            self.nextButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Select Picture
    @IBAction func selectPictureHandler(_ sender: UIButton) {
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    /// Button Next
    @IBAction func nextButtonHandler(_ sender: UIButton) {
        //if
        guard self.name.text != "", self.email.text != "", self.pwd.text != "", self.confirmPwd.text != "" else {
            print("All fields required")
            return
        }
        if self.pwd.text == self.confirmPwd.text {
            FIRAuth.auth()?.createUser(withEmail: self.email.text!, password: self.pwd.text!, completion: { (user, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                if let user = user {
                    
                    //to display who posted it
                    let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                    changeRequest.displayName = self.name.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let imageFromImageView = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.put(imageFromImageView!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imageRef.downloadURL(completion: { (url, er) in
                            if er != nil {
                                print(er!.localizedDescription)
                            }
                            if let url = url {
                                
                                let userInfo: [String : Any] = ["uid": user.uid,
                                                                "full name": self.name.text!,
                                                                "urlToImage": url.absoluteString]
                                
                                self.dataBase.child("users").child(user.uid).setValue(userInfo)
                                
                                let userViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC")
                                self.present(userViewController, animated: true, completion: nil)
                                
                            }
                        })
                    })
                    
                    uploadTask.resume()
                }
            })
            
        } else {
            print("Password does not match")
        }
    }
    
    fileprivate func setupView() {
        setBorderToButton(button: self.selectPicture, width: BUTTON_BORDER_WIDTH, color: BUTTON_COLOR)
        setBorderToButton(button: self.nextButton, width: BUTTON_BORDER_WIDTH, color: BUTTON_COLOR)
    }
    
}
