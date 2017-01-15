//
//  LoginViewController.swift
//  MonsterFeed
//
//  Created by Artem on 1/13/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import QuartzCore
import Firebase

func setBorderToButton(button: UIButton, width: Float, color: UIColor) {
    button.layer.borderWidth = CGFloat(width)
    button.layer.borderColor = color.cgColor
}

let BUTTON_COLOR = UIColor.white
let BUTTON_BORDER_WIDTH: Float = 1.0

///  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setBorderToButton(button: logInButton, width: BUTTON_BORDER_WIDTH, color: BUTTON_COLOR)
        setBorderToButton(button: signUpButton, width: BUTTON_BORDER_WIDTH, color: BUTTON_COLOR)
        
        
    }
    
    @IBAction func loginButtonHandler(_ sender: UIButton) {
        
        guard self.loginTextField.text != "", self.passwordTextField.text != "" else { return }
        
        FIRAuth.auth()?.signIn(withEmail: loginTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
            
            if let _ = user {
                
                let usersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UsersVC")
                
                self.present(usersViewController, animated: true, completion: nil)
            }
            
        })
        
    }
    
    
}
