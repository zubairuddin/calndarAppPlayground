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


class  ViewController: UIViewController {

    var eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var calendarArray = [EKEvent]()
    

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
        print(startDatePicker.date)
        print(endDatePicker.date)
        print(calendarArray)
        
    }
    

}
    
  





