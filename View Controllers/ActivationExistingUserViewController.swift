//
//  ActivationExistingUserViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase


var existingUserLoggedIn = false


class ActivationExistingUserViewController: UIViewController {
    
    
    
    @IBOutlet weak var textCodeInput: UITextField!

    @IBOutlet weak var resendCodeButton: UIButton!
    
    
    @IBOutlet weak var loginButtonOldUserSettings: UIButton!
    
    
     
    
    @IBAction func loginButtonOldUser(_ sender: UIButton) {
        
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: textCodeInput.text!)
               Auth.auth().signIn(with: credential) { (authResult, error) in
                       if error != nil {
                           print(error!)
                           return
                       }
                       else{
                        print("logged in")
                        
                        existingUserLoggedIn = true
                        
                        
                        UserDefaults.standard.set(loginPhoneNumber, forKey: "userPhoneNumber")
                        
                        self.performSegue(withIdentifier: "existingUserLoggedIn", sender: self)
        
    }
        
        
    }
    
    }

    
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
    
    PhoneAuthProvider.provider().verifyPhoneNumber(loginPhoneNumber, uiDelegate: nil) { (verificationID, error) in
        if let error = error {
            print(error)
            return
        }
        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
    }
    
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.setNavigationBarHidden(false, animated: false)

        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationItem.hidesBackButton = false
        
        //        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        loginButtonOldUserSettings.layer.borderColor = UIColor.lightGray.cgColor
        loginButtonOldUserSettings.layer.borderWidth = 2
        loginButtonOldUserSettings.layer.cornerRadius = 5
        loginButtonOldUserSettings.layer.backgroundColor = UIColor.white.cgColor

        loginButtonOldUserSettings.layer.shadowColor = UIColor.lightGray.cgColor
        loginButtonOldUserSettings.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        loginButtonOldUserSettings.layer.shadowRadius = 4
        loginButtonOldUserSettings.layer.shadowOpacity = 0.5
        loginButtonOldUserSettings.layer.masksToBounds = false
         loginButtonOldUserSettings.alpha = 0.9
        
        resendCodeButton.layer.borderColor = UIColor.lightGray.cgColor
        resendCodeButton.layer.borderWidth = 2
        resendCodeButton.layer.cornerRadius = 5
        resendCodeButton.layer.backgroundColor = UIColor.white.cgColor
        
        resendCodeButton.layer.shadowColor = UIColor.lightGray.cgColor
        resendCodeButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        resendCodeButton.layer.shadowRadius = 4
        resendCodeButton.layer.shadowOpacity = 0.5
        resendCodeButton.layer.masksToBounds = false
         resendCodeButton.alpha = 0.9
        
        resendCodeButton.isHidden = true
        
        perform(#selector(showResendButton), with: self, afterDelay: 20)
        
        

    }
    
    
    @objc func showResendButton() {
          resendCodeButton.isHidden = false
      }
    
    
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
