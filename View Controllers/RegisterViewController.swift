//
//  RegisterViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FlagPhoneNumber
import MBProgressHUD


var registeredName = String()
var registeredEmail = String()

class RegisterViewController: UIViewController {
  
    var verificationID: String = ""
    var ref: DocumentReference? = nil
    var settings = dbStore.settings
    var myAddedUserID = ""
    
    
    @IBOutlet var registerEmail: UITextField!
    
    @IBOutlet var registerName: UITextField!
    
    
    
    @IBOutlet weak var headerLabel: UILabel!
    
    
    @IBOutlet weak var registerEmailNextButtonSettings: UIButton!
    

    @IBAction func registerEmailNextButton(_ sender: Any) {
        print(registerName.text as Any)
        print(registerEmail.text as Any)
        
        
        if registerEmail.text == "" {
        
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Please eneter your email"
        loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
        loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)}
        
        else if registerName.text == "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please eneter your name"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
            
        }
            
        else if isValidEmail(emailStr: registerEmail.text!) == false{
            
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please eneter a valid email address"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
            
            
        }
        
        else{
            
            registeredName = registerName.text!
            registeredEmail = registerEmail.text!
            
            UserDefaults.standard.set(registerName.text, forKey: "name")
            
            self.performSegue(withIdentifier: "registerEmailName", sender: self)
  
        }}
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = "Add Details"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        
            self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        navigationItem.hidesBackButton = false
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        navigationController?.setNavigationBarHidden(false, animated: false)

        dbStore.settings = settings
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
//        self.view.addGestureRecognizer(tapGesture)
        
        
        //        setup next button
        
        registerEmailNextButtonSettings.layer.borderColor = UIColor.lightGray.cgColor
        registerEmailNextButtonSettings.layer.borderWidth = 2
        registerEmailNextButtonSettings.layer.cornerRadius = 5
        registerEmailNextButtonSettings.layer.backgroundColor = UIColor.white.cgColor
        
        registerEmailNextButtonSettings.layer.shadowColor = UIColor.lightGray.cgColor
        registerEmailNextButtonSettings.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        registerEmailNextButtonSettings.layer.shadowRadius = 4
        registerEmailNextButtonSettings.layer.shadowOpacity = 0.5
        registerEmailNextButtonSettings.layer.masksToBounds = false
        
        
        registerEmailNextButtonSettings.alpha = 0.90
        registerName.alpha = 0.90
        registerEmail.alpha = 0.90
        
        
        let welcomeText = NSMutableAttributedString(string: "Circle",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        welcomeText.append(NSMutableAttributedString(string: "it",
                                                    attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 65),NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        
        headerLabel.attributedText = welcomeText
        
        
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
    
    
     func isValidEmail(emailStr:String) -> Bool {

        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    

    

        }


