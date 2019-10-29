//
//  EventCreation - Contacts Input.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import DLRadioButton
import MBProgressHUD
import Firebase
import Alamofire


var currentLocale = NSLocale.current.regionCode
var selectedContacts: [String] = [""]
var eventCreationID = String()
var nonExistingUsers = [String]()
var nonExistingNumbers = [String]()

class EventCreation___Contacts_Input: UIViewController, UITableViewDataSource, UITableViewDelegate, CellSubclassDelegate2 {
    
    

    

//    variable to describe the time, in seconds, from GMT of the user
    var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
    
//    other variables
    var userIDArray = Array<String>()
    var fireStoreRef: DocumentReference? = nil
    var myAddedUserName = String()
    var userNameArray = Array<String>()
    var myAddedUserID = String()
    
    
    
    
    
    
    @IBOutlet weak var invitedFriendsTableView: UITableView!
    
    
    
    @IBAction func createEventButton(_ sender: Any) {
        
//        validation to ensure sure the user has added some contacts
        if contactsSelected.count == 0 {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
        loadingNotification.label.text = "Please select contacts to invite to your event"
        loadingNotification.label.adjustsFontSizeToFitWidth = true
        loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
        loadingNotification.mode = MBProgressHUDMode.customView
        loadingNotification.hide(animated: true, afterDelay: 2)

    }
        else{
            
//            performSegue(withIdentifier: "eventCreatedSegue", sender: Any.self)
            
            performSegue(withIdentifier: "eventSummarySegue", sender: Any.self)
        
//            addEventToEventStore(){
                
                
//            }
        
        }}
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Invitees"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor.black
        
//        allows this view controller to present alerts
//        definesPresentationContext = true
        
        //        set the background colour
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        invitedFriendsTableView.dataSource = self
        invitedFriendsTableView.delegate = self
        
        self.invitedFriendsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none

        invitedFriendsTableView.rowHeight = 60
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(editSelected))
    
}


//    Segue to edit the event page
@objc func editSelected(){
    
    performSegue(withIdentifier: "selectFriendsSegue", sender: self)
    
    
  
}
    
//    the user selected the delete button in the tableview
    @objc func deleteButtonPressed2(indexPath: IndexPath){
        print("delete button pressed")
    }
    
func buttonTapped2(cell: CollectionViewCellAddFriends) {
    guard let indexPath = self.invitedFriendsTableView.indexPath(for: cell) else {
        print("something went wrong when selecting to remove a user")
        // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
        return
    }
    
//    do what we need to with the information
    
    print("user selected section: \(indexPath.section)")
    
    //    DEVELOPMENT - how do we remove the removed user from the sorted contactcs list
    let index = contactsSorted.index(where: { $0.name == contactsSelected[indexPath.section].name})!

    contactsSorted[index].selectedContact = false
    
    
    contactsSelected.remove(at: indexPath.section)
    invitedFriendsTableView.reloadData()
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
//        reloads the tableview once the user has finished choosing the invitees
        invitedFriendsTableView.reloadData()
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        if contactsSelected.count == 0{
            
            return 1
        }
        else{
            return contactsSelected.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
    return 1
  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = invitedFriendsTableView.dequeueReusableCell(withIdentifier: "selectedContactCell", for: indexPath) as? CollectionViewCellAddFriends
                else{
                    fatalError("failed to create user created events cell")
            }
        
        
        
        if contactsSelected.count == 0{
            
            cell.addFriendsLabel.text = "Select friends using the 'Add' button above"
            cell.deleteUserButton.isHidden = true
            
            
            
        }
        else{
            let item = contactsSelected[indexPath.section]
            cell.addFriendsLabel.text = item.name
            cell.deleteUserButton.isHidden = false
            cell.backgroundColor = UIColor.white
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 1
            cell.clipsToBounds = true
        }
        
        cell.addFriendsLabel.adjustsFontSizeToFitWidth = true
        cell.delegate = self
        
        return cell
    }
    
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cellSpacingHeight: CGFloat = 10
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){

//        if segue.identifier == "eventCreatedSegue"{
//
//            print("Selected contacts array \(contactsSelected)")
//            addEventToEventStore {
//
//            }}
        
        if segue.identifier == "selectFriendsSegue"{
            
           selectedContacts.removeAll()
            
        }
    }
    
    
    
    //    MARK: code to add an event to the Firebase database
    
    
//    collection of all functions required to add the event
    func addEventToEventStore(completion: @escaping () -> Void){
        notExistingUserArray.removeAll()
        var selectedPhoneNumbers = [String]()
        var selectedNames = [String]()
        let currentUserID = Auth.auth().currentUser?.uid
        let eventOwnerName = UserDefaults.standard.string(forKey: "name")

        eventQuery { (eventID) in
            print("event commited to the database")
            print("eventID: \(eventID)")
        
        selectedPhoneNumbers = self.getSelectedContactsPhoneNumbers2().phoneNumbers
        selectedNames = self.getSelectedContactsPhoneNumbers2().names
        
        self.createUserIDArrays(phoneNumbers: selectedPhoneNumbers, names: selectedNames) { (nonExistentArray, existentArray, userNameArray, nonExistentNameArray) in
            
            print("nonExistentArray \(nonExistentArray)")
            print("existentArray \(existentArray)")
            
            //           adds the non users to the database
            self.addNonExistingUsers2(phoneNumbers: nonExistentArray, eventID: eventID, names: nonExistentNameArray)
            
            //            Adds the user event link to the userEventStore
            
            self.userEventLinkArray(userID: existentArray + [currentUserID!], userName: userNameArray + [eventOwnerName ?? ""], eventID: eventID)
            
            self.addUserIDsToEventRequests(userIDs: existentArray, currentUserID: [currentUserID!], existingUserIDs: [], eventID: eventID, addCurrentUser: true)
            
            
            if nonExistentArray.isEmpty == false{
                
            print("there are some invitees that arent users")
                
                nonExistingUsers = nonExistentNameArray
                nonExistingNumbers = nonExistentArray
                self.eventAdditionComplete()
                
                
//                self.inviteFriendsPopUp(notExistingUserArray: nonExistentArray, nonExistingNameArray: nonExistentNameArray)
                
                contactsSelected.removeAll()
                inviteesNamesNew.removeAll()
                contactsSorted.removeAll()
                contactsFiltered.removeAll()
                completion()

            }
            else{
                
                print("there are no invitees that arent users")
                
                self.eventAdditionComplete()
                    contactsSelected.removeAll()
                    inviteesNamesNew.removeAll()
                    contactsSorted.removeAll()
                    contactsFiltered.removeAll()
                completion()
                
  
            }

            }

        }
        
    }

    
//    get the phone numbers of the users selected for the event
    func getSelectedContactsPhoneNumbers( completion: @escaping () -> Void){
        selectedContacts.removeAll()
        
        getCurrentUsersPhoneNumber {
            
            
            for contact in contactsSelected{
                if contact.selectedContact == true {
                    
                    let phoneNumber = contact.phoneNumber
                    
                    let cleanPhoneNumber = self.cleanPhoneNumbers(phoneNumbers: phoneNumber)
                    
                        selectedContacts.append(cleanPhoneNumber)
                    }}
            print("Selected Contacts Phone Numbers \(selectedContacts)")
            completion()
            
        }}
    
    

    
//    get the current users phone number
    func getCurrentUsersPhoneNumber( completion: @escaping () -> Void){
        
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments{ (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents{
                    let usersPhoneNumber = document.get("phoneNumber")
                    selectedContacts.append(usersPhoneNumber as! String)
                    print("Current users phone number to add to selected contacts \(selectedContacts)")
                }}
            completion()
        }}
    
    
    
    
    //    Adds the new event into the evetRequests table
    func eventQuery( completion: @escaping (_ eventID: String) -> Void){
        
        let timestamp = NSDate().timeIntervalSince1970
        let eventOwnerName = UserDefaults.standard.string(forKey: "name")
        let ref = Database.database().reference()
        
        getStartAndEndDates3(startDate: newEventStartDate, endDate: newEventEndDate, startTime: newEventStartTimeLocal, endTime: newEventEndTimeLocal, daysOfTheWeek: daysOfTheWeekNewEvent){(startDates,endDates) in
            
            let eventSearchArray: [String:Any] = ["startDateInput": newEventStartDate,"endDateInput": newEventEndDate,"startTimeInput": newEventStartTime,"endTimeInput": newEventEndTime,"daysOfTheWeek": daysOfTheWeekNewEvent,"isAllDay": "0","users": self.userIDArray, "eventOwner": user!, "location": newEventLocation, "eventDescription": newEventDescription, "timeStamp": timestamp, "eventOwnerName":  eventOwnerName ?? "", "secondsFromGMT": self.secondsFromGMT/3600, "startDates": startDates, "endDates": endDates]
            
            print("days of the week eventQuery \(daysOfTheWeek)")
            
            self.fireStoreRef = dbStore.collection("eventRequests").addDocument(data: eventSearchArray as [String : Any]){
                error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    //                print("Document added with ID: \(ref!.documentID)")
                    
                    
                }
                
                eventCreationID  = self.fireStoreRef!.documentID
//                ref.child("events/\(eventCreationID)/\(newEventDescription)").setValue(newEventDescription)
//                ref.child("events/\(eventCreationID)/\(eventOwnerName ?? "")").setValue(eventOwnerName ?? "")
//                ref.child("events/\(eventCreationID)/\(newEventLocation)").setValue(newEventLocation)
                print("eventID from eventQuery \(eventCreationID)")
                completion(eventCreationID)
                
            }
            
            
        }
        
        

        
        
    }

  
}

