//
//  RegisterViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


class RegisterViewController: UIViewController {

    @IBOutlet var phoneNumberRegister: UITextField!
    
    @IBOutlet var registerEmail: UITextField!
    
    @IBOutlet var registerName: UITextField!
    
    @IBOutlet var verificationCode: UITextField!
    
    var verificationID: String = ""
    var ref: DocumentReference? = nil
    var settings = dbStore.settings
    var myAddedUserID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settings.areTimestampsInSnapshotsEnabled = true
        dbStore.settings = settings
        
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

            
            let dbStore = Firestore.firestore()
            

        

            
            //        LO: this says what we are going to be saving down to the DB
            
            let userDictionary = ["phoneNumer": Auth.auth().currentUser?.phoneNumber,"name": self.registerName.text, "email": self.registerEmail.text, "uid": uid]
            
            dbStore.collection("users").whereField("uid", isEqualTo: uid!).getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error getting documents: \(error!)")
                }
                else {
                    for document in querySnapshot!.documents {
                    
                        self.myAddedUserID = document.get("uid") as! String
                        
                        if self.myAddedUserID == uid {
                            
                        }
                        else{
                           self.ref = dbStore.collection("users").addDocument(data: userDictionary as [String : Any])
                            
                        }

                    }
                }
            }
            
            self.performSegue(withIdentifier: "registerComplete", sender: self)
            
            print("signed in")
            // User is signed in
            // ...
        }
        
                    }
    

    
    
}
