//
//  HomePageViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 25/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase



class HomePageViewController: UIViewController {
    
    
    
    //Zubair: Can we use initials while creating outlets such as lbl for labels, btn for buttons, img for ImageViews. E.g. lblUserName, btnSaveUser, imgUserImage. This way you won't have to remember the name of the outlet you have created while trying to use it later on and when you type the initial let's say lbl, Xcode will give you suggestions and you can select the appropriate label.
    
    @IBOutlet weak var openingTitleLabel: UILabel!
    @IBOutlet weak var loginButtonSettings: UIButton!
    @IBOutlet weak var oldUserButton: UIButton!
    
    @IBAction func oldUserButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "oldUserSegue", sender: self)
    }
    
    
    
    
    @IBAction func loginButton(_ sender: Any) {
        
        checkLogInButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let navLabel = UILabel()
//        let navTitle = NSMutableAttributedString(string: "Circle", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25),NSAttributedString.Key.foregroundColor: UIColor.black])
        
//        navTitle.append(NSMutableAttributedString(string: "it", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
//        navLabel.attributedText = navTitle
        
//        navigationItem.titleView = navLabel
//        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        
        
        //Zubair: Let's use functions whenever a task that requires more than 5-6 lines of code to make everything more readable.
        //The remaining code in viewDidLoad can easily be written into 2 separate functions
        view.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
        
        //Zubair: You are using exactly the same code to format loginButtonSettings and oldUserButton. You can easily do that inside a function passing a UIButton as parameter so that you won't have to repeat the same code again for multiple buttons.
        
              loginButtonSettings.layer.borderColor = UIColor.lightGray.cgColor
              loginButtonSettings.layer.borderWidth = 2
              loginButtonSettings.layer.cornerRadius = 5
              loginButtonSettings.layer.backgroundColor = UIColor.white.cgColor
              
              loginButtonSettings.layer.shadowColor = UIColor.lightGray.cgColor
              loginButtonSettings.layer.shadowOffset = CGSize(width: 0, height: 0.5)
              loginButtonSettings.layer.shadowRadius = 4
              loginButtonSettings.layer.shadowOpacity = 0.5
              loginButtonSettings.layer.masksToBounds = false
        
            loginButtonSettings.alpha = 0.90
        
            oldUserButton.layer.borderColor = UIColor.lightGray.cgColor
              oldUserButton.layer.borderWidth = 2
              oldUserButton.layer.cornerRadius = 5
              oldUserButton.layer.backgroundColor = UIColor.white.cgColor
              
              oldUserButton.layer.shadowColor = UIColor.lightGray.cgColor
              oldUserButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
              oldUserButton.layer.shadowRadius = 4
              oldUserButton.layer.shadowOpacity = 0.5
              oldUserButton.layer.masksToBounds = false
        
            oldUserButton.alpha = 0.90
        
            navigationItem.hidesBackButton = true
        
        
//        only check the users authentication state if they havent just logged out, the check should log in the user in automatically
        if justSignedOutBool == false{
            print("user hasn't just signed out")
            checkLogIn()
        }
        else{
            
            print("user has just signed out")
        }
        
        
        let welcomeText = NSMutableAttributedString(string: "Circle",
                                                    attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 60),NSAttributedString.Key.foregroundColor: UIColor.white])
        
        welcomeText.append(NSMutableAttributedString(string: "it",
                                                    attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 65),NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        
//        welcomeText.append(NSMutableAttributedString(string: "!\n\nIt doesn't have to take hours of chat messages to organise time with friends, join the App that makes it happen instantly.",attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        openingTitleLabel.attributedText = welcomeText
        loginButtonSettings.backgroundColor = UIColor.white
        
        
    }
    
    
    func checkLogIn(){
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                
                print("Auth: \(auth)")
                print("User: \(String(describing: user))")
                
                self.performSegue(withIdentifier: "existingUserSegue2", sender: self)
            } else {
//                self.performSegue(withIdentifier: "newUserSegue", sender: self)
            }
        }
        
    }
    
    
        func checkLogInButton(){
            
            Auth.auth().addStateDidChangeListener { auth, user in
                
                print("Auth: \(auth), user: \(String(describing: user))")
                
                if user != nil {
                    self.performSegue(withIdentifier: "existingUserSegue2", sender: self)
                } else {
                    self.performSegue(withIdentifier: "newUserSegue", sender: self)
                }
            }
            
        }

}
