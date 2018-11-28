//
//  LoginViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var loginEmail: UITextField!
    @IBOutlet var loginPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    


    
}
////    sign in with phone number
//        @IBAction func logInPressed(_ sender: UIButton) {
//
//            let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
//
//            let credential = PhoneAuthProvider.provider().credential(
//                withVerificationID: verificationID!,
//                verificationCode: self.verificationCode.text!)
//
//            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
//                if error != nil {
//                    // ...
//                    return
//                }
//
//                self.performSegue(withIdentifier: "registerComplete", sender: self)
//
//                print("signed in")
//                // User is signed in
//                // ...
//            }
//        }
    
//original login with email and passowrd
    @IBAction func logInPressed(_ sender: UIButton) {

        Auth.auth().signIn(withEmail: loginEmail.text!, password: loginPassword.text!) { (user, error) in
            if error != nil{
                print(error!)
            }else{
                print("Log In Complete")
                self.performSegue(withIdentifier: "logInComplete", sender: self)
            }

        }
    }
    
}
