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
    
    @IBOutlet var registerName: UITextField!
    
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
                print(error!)
                print("Didn't Work")
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        print(verificationID!)
        
        }
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        print(verificationID!)
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode.text!)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if error != nil {
                print(error!)
                return

           
            }
            let uid = Auth.auth().currentUser?.uid

            let db = Database.database().reference().child("Users")
            //        LO: this says what we are going to be saving down to the DB
            
            let userDictionary = ["PhoneNumer": Auth.auth().currentUser?.phoneNumber,"Name": self.registerName.text, "email": self.registerEmail.text]
            
            db.child(uid!).setValue(userDictionary)
            
            self.performSegue(withIdentifier: "registerComplete", sender: self)
            
            print("signed in")
            // User is signed in
            // ...
        }
        
                    }
    

    
    
}
