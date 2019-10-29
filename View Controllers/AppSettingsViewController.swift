//
//  AppSettingsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/10/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

var justSignedOutBool = false

class AppSettingsViewController: UIViewController {

    
    
    @IBOutlet weak var toolTipToggle: UISwitch!
    
    
    @IBOutlet weak var signOutButton: UIButton!
    
    
    
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
            let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
          performSegue(withIdentifier: "signOutSegue", sender: self)
            
            justSignedOutBool = true
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        
    }
    
    
    
    
    
    @IBAction func toolTipSwitch(_ sender: UISwitch) {
        
        if (sender.isOn == true){
            UserDefaults.standard.set(true, forKey: "permenantToolTips")
        }
        
        if (sender.isOn == false){
            UserDefaults.standard.set(false, forKey: "permenantToolTips")
        }
        
        
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "App Settings"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        
        
        signOutButton.layer.borderColor = UIColor.lightGray.cgColor
        signOutButton.layer.borderWidth = 2
        signOutButton.layer.cornerRadius = 5
        signOutButton.layer.backgroundColor = UIColor(red: 0, green: 176, blue: 156).cgColor
        
        signOutButton.layer.shadowColor = UIColor.lightGray.cgColor
        signOutButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        signOutButton.layer.shadowRadius = 4
        signOutButton.layer.shadowOpacity = 0.5
        signOutButton.layer.masksToBounds = false
        
        
        
        if UserDefaults.standard.bool(forKey: "permenantToolTips") == true {
            
            toolTipToggle.isOn = true
        }
        else{
            
            toolTipToggle.isOn = false
            
        }
        
        
        
        
    }
    



}
