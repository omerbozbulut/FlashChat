//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    // Alert
                    let alert = UIAlertController(title: nil, message: e.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okey", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }else{
                    // user created
                    self.performSegue(withIdentifier: "RegisterToChat", sender: self)
                }
          
        }
    }
    
}
    
    
}
