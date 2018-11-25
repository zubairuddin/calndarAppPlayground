//
//  RegisterViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase



class RegisterViewController: UIViewController {


    @IBOutlet var registerEmail: UITextField!
    
    @IBOutlet var registerPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: registerEmail.text!, password: registerPassword.text!) { (user, error) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Registration success")
                self.performSegue(withIdentifier: "registerComplete", sender: self)
            }
        }
                
            }
    
}
