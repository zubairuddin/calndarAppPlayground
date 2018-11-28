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

    @IBOutlet var phoneNumberRegister: UITextField!
    
    @IBOutlet var registerEmail: UITextField!
    
    @IBOutlet var registerPassword: UITextField!
    

    @IBOutlet var verificationCode: UITextField!
    
    var verificationID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

//initial register pressed for email sing in
//    @IBAction func registerButtonPressed(_ sender: UIButton) {
//
//        Auth.auth().createUser(withEmail: registerEmail.text!, password: registerPassword.text!) { (user, error) in
//
//            if error != nil {
//                print(error!)
//            }
//            else {
//                print("Registration success")
//                self.performSegue(withIdentifier: "registerComplete", sender: self)
//            }
//        }
//
//            }
    
    
    @IBAction func phoneNumberRegisterPressed(_ sender: UIButton) {
    PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberRegister.text!, uiDelegate: nil) { (verificationID, error) in
            if error != nil {
                print("didnt work")
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: self.verificationCode.text!)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
                // ...
                return
            }
            
            self.performSegue(withIdentifier: "registerComplete", sender: self)
            
            print("signed in")
            // User is signed in
            // ...
        }
        
                    }
    

    
    
}
