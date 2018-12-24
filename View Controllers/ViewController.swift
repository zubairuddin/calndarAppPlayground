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
import EventKit
import RealmSwift

var settings = dbStore.settings
var dbStore = Firestore.firestore()


class  ViewController: UIViewController {
    
    //    required to initiate realm
    let realm = try! Realm()
    var realmResults: Results<CalendarEventRealm1>!
    
    //    variables for the apple event calendar
    var eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var calendarArray = [EKEvent]()
    var calendarEventArray : [Event] = [Event]()
    
    //    variables for the search dates chosen
    let dateFormatter = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    var startDateEnd = Date()
    var isAllDay: Bool = false
    

    
    
    var userIDArray = Array<String>()
    var ref: DocumentReference? = nil
    var user = Auth.auth().currentUser?.uid
    var myAddedUserID: String = ""
    var eventCreationID: String = ""
    var textPassedOver : String?
    var contactsList = [contactList]()
    var selectedContacts: [String] = [""]
    var numberOfItems = 1
    var datesBetweenChosenDatesStart = Array<Date>()
    var datesBetweenChosenDatesEnd = Array<Date>()
    var datesOfTheEvents = Array<Date>()
    var startDatesOfTheEvents = Array<Date>()
    var startEndDate = Date()
    var finalAvailabilityArray = Array<Int>()
    var eventLocation = ""
    var eventDescription = ""
    
//    the variables below are the required variables for the event search
    var startDateInput = "2018-11-01"
    var endDateInput = "2018-12-31"
    var startTimeInput = "06:00"
    var endTimeInput = "16:00"
    //    when the days of the week we are looking for are input inot the array, they should be input with their corrcet integer day, all other unrequired days should be input with a random integer e.g. 10 below
    var daysOfTheWeek = [10,1,2,10,10,10,10]
    
    var newEventID = ""
    
    
//    variables for the list of events
    var userEventList = [eventSearch]()
    
    
    @IBAction func toContactsForEvent(_ sender: UIButton) {
        
       performSegue(withIdentifier: "toContactsPage", sender: self)
        
       selectedContacts.removeAll()
        
    }
        
    
//    Run The Code Button
    @IBAction func contactsCodeRun(_ sender: UIButton) {

        settings.areTimestampsInSnapshotsEnabled = true
        dbStore.settings = settings
        
        getUsersCreatedEvents()
        
    }
    
    @IBAction func getEventAvailability(_ sender: UIButton) {
        
        checkCalendarStatus()
        requestAccessToCalendar()
        getCalendarData()
        getArrayOfChosenDates()
        getArrayOfChosenDatesEnd()
        compareTheEventTimmings()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings.areTimestampsInSnapshotsEnabled = true
        dbStore.settings = settings
        
        //        capital HH denotes the 24hr clock
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDate = dateFormatter.date(from: startDateInput + " " + startTimeInput)!
        
        //        these two elements must contain the same time HH:mm:ss
        startEndDate = dateFormatter.date(from: startDateInput + " " + endTimeInput)!
        endDate = dateFormatter.date(from: endDateInput + " " + endTimeInput)!
        
        
        try! realm.write {
            realm.deleteAll()
        }

        
//        listener to detect when any events are added with mu user name in them
        dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New event: \(diff.document.data())")
                    
                    let userEventStoreID = diff.document.documentID
                    
                    self.newEventID = diff.document.get("eventID") as! String
                    
                    self.getEventInformation(eventID: self.newEventID, completion: {
                        print("Succes getting the event data")
                        
                        self.checkCalendarStatus()
                        self.requestAccessToCalendar()
                        self.getCalendarData()
                        self.getArrayOfChosenDates()
                        self.getArrayOfChosenDatesEnd()
                        self.compareTheEventTimmings()
                        
                        
//                        add the finalAvailabilityArray to the userEventStore
                        
                        dbStore.collection("userEventStore").document(userEventStoreID).setData(["userAvailability" : self.finalAvailabilityArray], merge: true)
                        
                    })
                    
                    
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
    
    
    
    //    MARK: code to add an event to the Firebase database
    
    func addEventToEventStore(completion: @escaping () -> Void){
      
        getSelectedContactsPhoneNumbers {
            self.eventQuery {
            for attendees in self.selectedContacts {
            
            self.getUserIDs(phoneNumber: attendees) {
                    
                self.userEventLink(userID: self.myAddedUserID, eventID: self.eventCreationID, completion: {
                    print("Complete")
                })
                    completion()
                    
                }}}}}
    
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
        
        let eventSearchArray: [String:Any] = ["startDateInput": startDateInput,"endDateInput": endDateInput,"startTimeInput": startTimeInput,"endTimeInput": endTimeInput,"daysOfTheWeek": daysOfTheWeek,"isAllDay": "0","users": "userList", "eventOwner": user!, "location": eventLocation, "eventDescription": eventDescription]
    
        
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
    
    
    
    func getEventInformation(  eventID:String, completion: @escaping () -> Void) {
        
        let docRef = dbStore.collection("eventRequests").document(eventID)
        
        docRef.getDocument(
            completion: { (document, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                self.startDateInput = document!.get("startDateInput") as! String
                    self.endDateInput = document!.get("endDateInput") as! String
                    self.startTimeInput = document!.get("startTimeInput") as! String
                    self.endTimeInput = document!.get("endTimeInput") as! String
                    self.daysOfTheWeek = document!.get("daysOfTheWeek") as! [Int]
                    
                    print(self.startDateInput)
                    print(self.endDateInput)
                    print(self.startTimeInput)
                    print(self.endTimeInput)
                    print(self.daysOfTheWeek)
                    
                    completion()
                }
            })
    }
    
    
    
    
    
    
    //    MARK: Code for searching our calendar starts here
    

    func checkCalendarStatus(){
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            print("We got access")
        case EKAuthorizationStatus.denied:
            print("No access")
            
        case .restricted:
            print("Access denied")
        }
        
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                print("we got access")
            }
            else{
                print("no access")
            }
            
        })
    }
    
    func getCalendarData()  {
        
        datesOfTheEvents.removeAll()
        startDatesOfTheEvents.removeAll()
        calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDate as Date, end: endDate as Date, calendars: calendars))
        
        //        print(calendarArray)
        
        numberOfItems = calendarArray.count
        
        //        print(numberOfItems)
        
        try! realm.write {
            realm.deleteAll()
        }
        
        
        
        for event in calendarArray{
            
            //            appends new items into the array calendarEventsArray
            let newItemInArray = Event()
            newItemInArray.alarms = event.alarms
            newItemInArray.title = event.title
            newItemInArray.location = event.location!
            newItemInArray.URL = event.url
            newItemInArray.lastModified = event.lastModifiedDate
            newItemInArray.startDate = event.startDate
            newItemInArray.endDate = event.endDate
            newItemInArray.allDay = event.isAllDay
            newItemInArray.recurrence = event.recurrenceRules
            newItemInArray.attendees = event.attendees
            newItemInArray.timezone = event.timeZone
            newItemInArray.availability = event.availability
            newItemInArray.occuranceDate = event.occurrenceDate
            
            calendarEventArray.append(newItemInArray)
            
            //            print(Event.init().title!)
            
            
            //            writes the data into Realm
            
            do{
                
                try self.realm.write{
                    
                    let newItemInArrayRealm = CalendarEventRealm1()
                    newItemInArrayRealm.eventIdentifier = event.eventIdentifier
                    newItemInArrayRealm.title = event.title
                    newItemInArrayRealm.endDate = event.endDate
                    newItemInArrayRealm.startDate = event.startDate
                    newItemInArrayRealm.location = event.location!
                    newItemInArrayRealm.allDay = event.isAllDay
                    newItemInArrayRealm.occuranceDate = event.occurrenceDate
                    realm.add(newItemInArrayRealm)
                    
                }
                
                //                creates an array of the dates on which the user has events
                datesOfTheEvents.append(event.occurrenceDate)
                startDatesOfTheEvents.append(event.startDate)
                
                //                print(startDatesOfTheEvents)
                
                
                //                prints the titles of the saved events
                //                print(newItemInArray.title!)
            }
            catch {
                print("Error saving new items, \(error)")
                
            }
            
        }
        //                    location of the realm file
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        
        
    }
    
    
    
    //    determines what day of the week the date is
    func getDayOfWeek(_ today:String) -> Int? {
        guard let todayDate = dateFormatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    
    //    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDates() {
        
        datesBetweenChosenDatesStart.removeAll()
        var currentDate = startDate
        let calendar = NSCalendar.current
        
        //        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {
            
            
            
            let myDateString = dateFormatter.string(from: currentDate)
            
            let dayOfWeek = getDayOfWeek(myDateString)
            
            if daysOfTheWeek.contains(dayOfWeek!) {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesStart.append(myDateNonString!)
                
                
                //                print(myDateString)
            }
            else {
                
            }
            
            //            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    
    
    //    Adds the dates between our start date and end date to the Array datesBetweenChosenDates
    func getArrayOfChosenDatesEnd() {
        
        datesBetweenChosenDatesEnd.removeAll()
        var currentDate = startEndDate
        let calendar = NSCalendar.current
        
        //        filters through the dates until the currentDate and endDate are equal
        while currentDate <= endDate {
            
            
            let myDateString = dateFormatter.string(from: currentDate)
            
            let dayOfWeek = getDayOfWeek(myDateString)
            
            
            if daysOfTheWeek.contains(dayOfWeek!) {
                
                let myDateNonString = dateFormatter.date(from: myDateString)
                
                datesBetweenChosenDatesEnd.append(myDateNonString!)
                
            }
            else {
                
                
            }
            
            //            Adds one day to the current date
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate as Date)!
        }
    }
    
    
    
    
    
    //    compares the timmings of the events we have to those specified by the user and returns those dates we are free
    func compareTheEventTimmings (){
        
        let numeberOfDatesToCheck = datesBetweenChosenDatesStart.count - 1
        let numberOfEventDatesToCheck = startDatesOfTheEvents.count - 1
        var n = 0
        var y = 0
        finalAvailabilityArray.removeAll()
        
        while y <= numeberOfDatesToCheck {
            
            while n <= numberOfEventDatesToCheck {
                
                if
                    (datesBetweenChosenDatesStart[y] ... datesBetweenChosenDatesEnd[y]).contains(startDatesOfTheEvents[n]) == true {
                    
                    finalAvailabilityArray.append(0)
                    
                }
                else {
                    
                    if n == numberOfEventDatesToCheck{
                        finalAvailabilityArray.append(1)}
                }
                n = n + 1
                
            }
            
            n = 0
            y = y + 1
        }
        print(finalAvailabilityArray)
    }
    
    
    
    
    //    MARK: code to pull down the events and display them
    
    func getUsersCreatedEvents(){
        
        dbStore.collection("eventRequests").whereField("eventOwner", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print("Error getting documents: \(error!)")
            }
            else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    
                    let nextUserEventToAdd = eventSearch()
                    
                    nextUserEventToAdd.eventDescription = document.get("eventDescription") as! String
                    nextUserEventToAdd.eventID = document.documentID
                    
                    self.userEventList.append(nextUserEventToAdd)
                    
                }
            }}}
    
    
    
    

}
