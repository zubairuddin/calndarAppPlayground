//
//  PhoneNumberInput.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


var registeredPhoneNumber = String()
var registeredPhoneNumbers = [String]()

class PhoneNumberInput: UIViewController {
    
    //Zubair: Please use appropriate initials for IBOutlets
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    
    
    @IBOutlet weak var additionalNumberLabel: UILabel!
    
    
    @IBOutlet weak var additionalPhoneNumberTextField: FPNTextField!
    
    
    @IBOutlet weak var getActiviationCodeSettings: UIButton!
    
    
    @IBAction func getActivationCodeButton(_ sender: Any) {
        
        if phoneNumberTextField.text == ""{
            
            print(phoneNumberTextField.text ?? "")
         
            //Zubair: If this is written within an extension, you would need to write it once and use anywhere
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please eneter your phone number"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
        
        else{
            
            //Zubair: Rather than using hard coded strings, use constants
            performSegue(withIdentifier: "getActiviationCode", sender: Any?.self)}
        
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = "Add Phone Number"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        //        move the view up when the keyboard is active
        
        //Zubair: I saw keyboard handling code written in multiple classes. This is again a very bad practice. You should either write the code in a custom class/protocol or use a third party library such as IQKeyboardManager.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        //Zubair: Again, multiple lines are written within viewDidLoad. Please try to avoid it and use functions whereever possible.
        
        //        code for the setup of the country picker
        phoneNumberTextField.borderStyle = .roundedRect
        
        // Comment this line to not have access to the country list
        phoneNumberTextField.parentViewController = self
        phoneNumberTextField.delegate = self
        
        phoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
        
        
        // Custom the size/edgeInsets of the flag button
        phoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
//        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
        phoneNumberTextField.hasPhoneNumberExample = true
        view.addSubview(phoneNumberTextField)
        
        
        additionalPhoneNumberTextField.borderStyle = .roundedRect
                
                // Comment this line to not have access to the country list
                additionalPhoneNumberTextField.parentViewController = self
                additionalPhoneNumberTextField.delegate = self
                
                additionalPhoneNumberTextField.font = UIFont.systemFont(ofSize: 14)
        
        additionalPhoneNumberTextField.alpha = 0.9
        phoneNumberTextField.alpha = 0.9
                
                // Custom the size/edgeInsets of the flag button
                additionalPhoneNumberTextField.flagButtonSize = CGSize(width: 35, height: 35)
        //        phoneNumberTextField.flagbutton = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                // The placeholder is an example phone number of the selected country by default. You can add your own placeholder :
                additionalPhoneNumberTextField.hasPhoneNumberExample = true
                view.addSubview(additionalPhoneNumberTextField)
        
        
        
        
        additionalNumberLabel.adjustsFontSizeToFitWidth = true
        
        
        registeredPhoneNumbers.removeAll()
        
        
        //        setup next button
               
        //Zubair: As I said earlier, if similar formatting is required for multiple UI components, it is must that you subclass those UI components.
               getActiviationCodeSettings.layer.borderColor = UIColor.lightGray.cgColor
               getActiviationCodeSettings.layer.borderWidth = 2
               getActiviationCodeSettings.layer.cornerRadius = 5
               getActiviationCodeSettings.layer.backgroundColor = UIColor.white.cgColor
               
               getActiviationCodeSettings.layer.shadowColor = UIColor.lightGray.cgColor
               getActiviationCodeSettings.layer.shadowOffset = CGSize(width: 0, height: 0.5)
               getActiviationCodeSettings.layer.shadowRadius = 4
               getActiviationCodeSettings.layer.shadowOpacity = 0.5
               getActiviationCodeSettings.layer.masksToBounds = false
        getActiviationCodeSettings.alpha = 0.9
        
    }

    //    gets the inputs for the contry flags
    private func getCustomTextFieldInputAccessoryView(with items: [UIBarButtonItem]) -> UIToolbar {
        let toolbar: UIToolbar = UIToolbar()
        
        toolbar.barStyle = UIBarStyle.default
        toolbar.items = items
        toolbar.sizeToFit()
        
        return toolbar
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "getActiviationCode"){
            
            if additionalPhoneNumberTextField.text == ""{
                
            
            let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
            
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print(error)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                
                UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
            }
            
          registeredPhoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
             registeredPhoneNumbers.append(registeredPhoneNumber)
  
            }
            
            else{
                
                let phoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164) ?? "E164: nil"
                  PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                      if let error = error {
                          print(error)
                          return
                      }
                      UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                  }
                  
                registeredPhoneNumber = phoneNumberTextField.getFormattedPhoneNumber(format: .E164)!
                   registeredPhoneNumbers.append(registeredPhoneNumber)
                
                registeredPhoneNumbers.append(additionalPhoneNumberTextField.getFormattedPhoneNumber(format: .E164)!)
                
                
                
            }
            
        }
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

extension PhoneNumberInput: FPNTextFieldDelegate {
    
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
    
    

}
