//
//  ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore


var settings = dbStore.settings
var dbStore = Firestore.firestore()


class  ViewController: UIViewController {
    
    var userIDArray = Array<String>()
    var ref: DocumentReference? = nil
    var user = Auth.auth().currentUser?.uid
    var myAddedUserID: String = ""
    var eventCreationID: String = ""
    let dateFormatter = DateFormatter()
    var textPassedOver : String?
    var contactsList = [contactList]()
    var selectedContacts: [String] = [""]
    
    
    
    
    
    @IBAction func toContactsForEvent(_ sender: UIButton) {
        
       performSegue(withIdentifier: "toContactsPage", sender: self)
        
       selectedContacts.removeAll()
        
    }
        
    
    
    @IBAction func contactsCodeRun(_ sender: UIButton) {

        settings.areTimestampsInSnapshotsEnabled = true
        dbStore.settings = settings
    
       addEventToEventStore()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        settings.areTimestampsInSnapshotsEnabled = true
        dbStore.settings = settings

        
//        listener to detect when any events are added with mu user name in them
        dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New event: \(diff.document.data())")
                }
//                if (diff.type == .modified) {
//                    print("Modified event: \(diff.document.data())")
//                }
//                if (diff.type == .removed) {
//                    print("Removed event: \(diff.document.data())")
//                }
            }
        }
        
    }
    
    
    func addEventToEventStore(){
      
        getSelectedContactsPhoneNumbers {
            self.eventQuery {
            for attendees in self.selectedContacts {
            
            self.getUserIDs(phoneNumber: attendees) {
                    
                self.userEventLink(userID: self.myAddedUserID, eventID: self.eventCreationID, completion: {
                    print("Complete")
                })
                    
                    
                }
                
            }}}}
    
    func addingToEventStoreForAllUser(){
        
        
        print(userIDArray)

    }
    

    

    
    func getUserIDs(  phoneNumber:String, completion: @escaping () -> Void) {
        
        dbStore.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    self.myAddedUserID = document.get("uid") as! String
//                    print(myAddedUserID)
                    self.userIDArray.append(self.myAddedUserID)
                    print(self.userIDArray)
                    completion()
                }
    }
        }
        
        
        
    }
    
    
    func eventQuery( completion: @escaping () -> Void){
        
        let eventSearchArray: [String:Any] = ["startSearchDate": "2018-01-01","endSearchDate": "2019-01-01", "sunday": "0", "monday": "1", "tuesday": "1", "wednesday": "0", "thursday": "0", "friday": "0", "isAllDay": "0", "saturday": "0", "users": "userList", "eventOwner": user!]
    
        
        ref = dbStore.collection("eventRequests").addDocument(data: eventSearchArray as [String : Any]){
            error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
//                print("Document added with ID: \(ref!.documentID)")

                
            }
            
            self.eventCreationID  = self.ref!.documentID
//            print(eventID)
            completion()
            
        }
        }
        
    
    func userEventLink( userID: String, eventID: String, completion: @escaping () -> Void){
        
        dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": userID])
        completion()
        
        
        
    }
    
    
    func getSelectedContactsPhoneNumbers( completion: @escaping () -> Void){
        selectedContacts.removeAll()
        for contact in contactsList{
        if contact.selectedContact == true {
            
            selectedContacts.append(contact.phoneNumber.replacingOccurrences(of: " ", with: ""))
            
            }}
        completion()
        print(selectedContacts)
    }
    

}
