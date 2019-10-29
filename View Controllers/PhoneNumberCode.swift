//
//  PhoneNumberCode.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class PhoneNumberCode: UIViewController {
    
    var myAddedUserID = ""
    var ref: DocumentReference? = nil
    
    @IBOutlet weak var textCodeInput: UITextField!
    
    @IBOutlet weak var completeRegistrationSettings: UIButton!
    
    @IBOutlet weak var resendButton: UIButton!
    
    
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        
        
        PhoneAuthProvider.provider().verifyPhoneNumber(registeredPhoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
        
        
        
    }
    
    
    @IBAction func completeRegistrationPressed(_ sender: Any) {
        
        print(registeredPhoneNumber)
        print(registeredEmail)
        print(registeredName)
    
        if textCodeInput.text != "" {
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        
        print(verificationID!)
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: textCodeInput.text!)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if error != nil {
                print(error!)
                return
    
            }
            else{
                
//                        self.performSegue(withIdentifier: "userRegistered2", sender: self)
                
            let uid = Auth.auth().currentUser?.uid
            
            let dbStore = Firestore.firestore()

            //        LO: this says what we are going to be saving down to the DB
            let userDictionary = ["phoneNumber": Auth.auth().currentUser?.phoneNumber! as Any,"name": registeredName, "email": registeredEmail, "uid": uid as Any, "phoneNumbers": registeredPhoneNumbers] as [String : Any]
            
//            Add the information to the database
            self.ref = dbStore.collection("users").addDocument(data: userDictionary as [String : Any])
            
            print("registeredPhoneNumbers.count: \(registeredPhoneNumbers.count)")
            
            if registeredPhoneNumbers.count == 1{
                
                print("1 registered number")
                
                self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]) {
                    print("Temporary invited added to database")
                    self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0])
                }
            }
            else{
                
                self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0]) {
                    print("Temporary invited added to database")
                    self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[0])
                }
                
                self.checkForPhoneNumberInvited(phoneNumber: registeredPhoneNumbers[1]) {
                    print("Temporary invited added to database")
                    self.deletePhoneNumberInvited(phoneNumber: registeredPhoneNumbers[1])
                }
    
            }
            print("signed in")
            print("Segue to homepage")

            // User is signed in
            // ...
            }
            
            }
            
        }
        
        else{
            
//        pop-up to let the user know they need to input the text code
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please eneter the text code"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
            
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = "Complete Registration"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
        
        //        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        //        setup next button
               
               completeRegistrationSettings.layer.borderColor = UIColor.lightGray.cgColor
               completeRegistrationSettings.layer.borderWidth = 2
               completeRegistrationSettings.layer.cornerRadius = 5
               completeRegistrationSettings.layer.backgroundColor = UIColor.white.cgColor
               
               completeRegistrationSettings.layer.shadowColor = UIColor.lightGray.cgColor
               completeRegistrationSettings.layer.shadowOffset = CGSize(width: 0, height: 0.5)
               completeRegistrationSettings.layer.shadowRadius = 4
               completeRegistrationSettings.layer.shadowOpacity = 0.5
               completeRegistrationSettings.layer.masksToBounds = false
                completeRegistrationSettings.alpha = 0.9
        
        
                resendButton.layer.borderColor = UIColor.lightGray.cgColor
                resendButton.layer.borderWidth = 2
                resendButton.layer.cornerRadius = 5
                resendButton.layer.backgroundColor = UIColor.white.cgColor
        
                resendButton.layer.shadowColor = UIColor.lightGray.cgColor
                resendButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
                resendButton.layer.shadowRadius = 4
                resendButton.layer.shadowOpacity = 0.5
                resendButton.layer.masksToBounds = false
                resendButton.alpha = 0.9
                resendButton.isHidden = true
        
        
                perform(#selector(showResendButton), with: self, afterDelay: 20)
        
                textCodeInput.alpha = 0.9
        
        
    }
    
    
    @objc func showResendButton() {
        resendButton.isHidden = false
    }
    
    
    //    MARK: section get any events the user has already been invited to, moved them from temporary and adds them to permenant, it then deletes the temporary entries
    
    func checkForPhoneNumberInvited(phoneNumber: String, completion: @escaping () -> Void){
        
        print("running func checkForPhoneNumberInvited, inputs: phoneNumber: \(phoneNumber)")
        dbStore.collection("temporaryUserEventStore").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    
                    let eventID = document.get("eventID") as! String
                    let uid = Auth.auth().currentUser?.uid
                    
                    //                    add the required info to the userEventStore
                    
                    dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": uid!, "userName": registeredName])
                    
                    //                    adds the uid to the eventRequests
                    
                    let docRef = dbStore.collection("eventRequests").document(eventID)
                    
                    docRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            dbStore.collection("eventRequests").document(eventID).updateData(["users" : FieldValue.arrayUnion([uid!])])
                            
                        } else {
                            print("Document does not exist")
                        }
                    }
                  completion()
                }
                
            }
            
        }}
    
    //    deletes the entry for the phone number into the temporaryUserEventStore
    func deletePhoneNumberInvited(phoneNumber: String){
        
        print("running func deletePhoneNumberInvited, inputs: phoneNumber \(phoneNumber)")
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        docRefUserEventStore.whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    print("deleted temporary document")
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).delete()
                }}}}
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}
