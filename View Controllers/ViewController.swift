//
//  ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase


var contactsArray = [
    contactList(name:"Aurelia Aubourg", phoneNumber:"+447845581394",selectedContact: true)]


var phoneNumber = "+447845581394"

var ref: DatabaseReference!

var user = Auth.auth().currentUser?.uid


let dateFormatter = DateFormatter()



class  ViewController: UIViewController {
    @IBAction func contactsCodeRun(_ sender: UIButton) {
        
        
        
        myContactListFirebase()
        getUserIDs()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
    }
    
    
    
    func myContactListFirebase(){
    
        let ref = Database.database().reference().child("eventSearches")
        
        let eventSearchArray: [String:Any] = ["startSearchDate": "2018-01-01","endSearchDate": "2019-01-01", "sunday": "0", "monday": "1", "tuesday": "1", "wednesday": "0", "thursday": "0", "friday": "0", "isAllDay": "0", "saturday": "0", "users": "userList"]
        
        
        ref.child(user!).setValue(eventSearchArray)
    
    }
    
    
    func getUserIDs(){
        
    let ref = Database.database().reference().child("users")
        
    let userID = ref.queryOrderedByKey()
        
        print(userID)
        
        
        
    }
    

        
    }
    
    

    
    

