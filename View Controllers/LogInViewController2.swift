//
//  LogInViewController2.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


var loginPhoneNumber = String()

class LogInViewController2: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    

    
    @IBOutlet weak var getActivationCodeButton: UIButton!
    
    
    @IBAction func getActivationCodePressed(_ sender: UIButton) {
        
 
        if phoneNumberTextField.text == ""{
            
            print(phoneNumberTextField.text ?? "")
         
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please eneter your phone number"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
   
        }
        
        else{
            
               self.performSegue(withIdentifier: "existingUserActivationSegue", sender: self)}
                    
                    
                }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        navigationItem.hidesBackButton = false
        
        //        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        phoneNumberTextField.delegate = self
        
        //        code for the setup of the country picker
                phoneNumberTextField.borderStyle = .roundedRect
                
                // Comment this line to not have access to the country list
                phoneNumberTextField.parentViewController = self
//                phoneNumberTextField.delegate = self
                
                phoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
                
                
                // Custom the size/edgeInsets of the flag button
                phoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
        //        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
                phoneNumberTextField.hasPhoneNumberExample = true
                view.addSubview(phoneNumberTextField)
        
        
                getActivationCodeButton.layer.borderColor = UIColor.lightGray.cgColor
               getActivationCodeButton.layer.borderWidth = 2
               getActivationCodeButton.layer.cornerRadius = 5
               getActivationCodeButton.layer.backgroundColor = UIColor.white.cgColor
               
               getActivationCodeButton.layer.shadowColor = UIColor.lightGray.cgColor
               getActivationCodeButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
               getActivationCodeButton.layer.shadowRadius = 4
               getActivationCodeButton.layer.shadowOpacity = 0.5
               getActivationCodeButton.layer.masksToBounds = false
                getActivationCodeButton.alpha = 0.9
        
    }
    
    
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if(segue.identifier == "existingUserActivationSegue"){
              

              let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
            
            loginPhoneNumber = phoneNumber
              PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                  if let error = error {
                      print(error)
                      return
                  }
                  UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
              }
              
  
          }
      }
    
    

}

extension LogInViewController2: FPNTextFieldDelegate {
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "Available") : #imageLiteral(resourceName: "Unavailable"))
        
        print(
            isValid,
            textField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil",
            textField.getFormattedPhoneNumber(format: .International) ?? "International: nil",
            textField.getFormattedPhoneNumber(format: .National) ?? "National: nil",
            textField.getFormattedPhoneNumber(format: .RFC3966) ?? "RFC3966: nil",
            textField.getRawPhoneNumber() ?? "Raw: nil"
        )
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
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

