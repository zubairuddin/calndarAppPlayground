//
//  ViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI
import Firebase
import Klendario



class  ViewController: UIViewController {

    var eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var calendarArray = [EKEvent]()
    var arrTest = [1,2,3]
    

    
    

    
    

//    input date for the start of our time period for looking for an event
    @IBOutlet var startDatePicker: UIDatePicker!
    
    
//    input date for the end of our time period for looking for an event
    @IBOutlet var endDatePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()}
    
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
    
    
    
//
    func getCalendarData()  {

        
       calendarArray = eventStore.events(matching: eventStore.predicateForEvents(withStart: startDatePicker.date, end: endDatePicker.date, calendars: calendars))
        
    }
    

    @IBAction func runTheCode(_ sender: UIButton) {
        
        checkCalendarStatus()
        getCalendarData()
        
        Klendario.getEvents(from: Date() - 20*100000,
                            to: Date() ,
                            in: calendars) { (events, error) in
                                guard let events = events else { return }
                                print("got \(events.count) events")
                                print(Date())
                                print(events.description)
                                let arrTest = events.description
                                
        }

        
//        //TODO: Send the message to Firebase and save it in our database
//        let messageDB = Database.database().reference().child("Message")
//
//        //        LO: this says what we are going to be saving down to the DB
//
//        let messsageDictionary = ["Sender": Auth.auth().currentUser?.email as Any,"CalendarInfo": calendarUW] as [String : Any]
//
//        //       LO: creates cutom random key for our message, allowing them to be saved with a unique identifier, saving our messaeg dictionary inside the message DB under an automatically generated ID
//        messageDB.childByAutoId().setValue(messsageDictionary) { (error, reference) in
//
//            if error != nil{
//                print(error!)}
//            else {
//                print("Message saved successfully")}}
        
        
        print(startDatePicker.date)
        print(endDatePicker.date)

        
    }
    

}
    
  





