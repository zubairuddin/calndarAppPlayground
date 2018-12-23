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



var phoneNumberArray = ["+447845581394","+447854937880"]
var userIDArray = Array<String>()
var ref: DocumentReference? = nil
var user = Auth.auth().currentUser?.uid
var dbStore = Firestore.firestore()
var settings = dbStore.settings
var myAddedUserID: String = ""
var eventCreationID: String = ""
let dateFormatter = DateFormatter()



class  ViewController: UIViewController {
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
      
        eventQuery {
            
            
            
            for attendees in phoneNumberArray {
            
            self.getUserIDs(phoneNumber: attendees) {
                    
                self.userEventLink(userID: myAddedUserID, eventID: eventCreationID, completion: {
                    print("Complete")
                })
                    
                    
                }
                
            }}}
    
        
    
    
//    func addEventToEventStore(completion: @escaping (_ success: Bool) -> Void){
//
//    let numberOfUsers = phoneNumberArray.count
//    var n = 0
//
//        while n <= numberOfUsers - 1 {
//
//            getUserIDs(phoneNumber: phoneNumberArray[n], completion: { success  -> Void in
//
//            if success == true {
//
//              n = n + 1
//
//            }else{
//
//              return
//            }
//
//            })
//
//
//
//        }
//        completion(true)
//
//    }
    

    
    
    
    func addingToEventStoreForAllUser(){
        
        
        print(userIDArray)
                
//                        let numberOfUsers = phoneNumberArray.count
//                        var n = 0
//
//                        //        will need to add inputs to the function to allow the users inputs to feed in
//                                eventQuery()
//                                n = 0
//                                while  n <= numberOfUsers - 1{
//
//                                    if n == 10 {
//                                        return
//                                    }else{
//
//                                    userEventLink(userID: userIDArray[n])
//                                        n = n + 1}
//                                }
    }
    

    

    
    func getUserIDs(  phoneNumber:String, completion: @escaping () -> Void) {
        
        dbStore.collection("users").whereField("phoneNumber", isEqualTo: phoneNumber).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    myAddedUserID = document.get("uid") as! String
//                    print(myAddedUserID)
                    userIDArray.append(myAddedUserID)
                    print(userIDArray)
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
            
            eventCreationID  = ref!.documentID
//            print(eventID)
            completion()
            
        }
        }
        
    
    func userEventLink( userID: String, eventID: String, completion: @escaping () -> Void){
        
        dbStore.collection("userEventStore").addDocument(data: ["eventID": eventID, "uid": userID])
        completion()
        
        
        
    }

}
    

