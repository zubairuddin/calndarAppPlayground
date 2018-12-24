//
//  CreateEventViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 24/12/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit



class CreateEventViewController: UIViewController {

    
    
    @IBOutlet weak var eventLocation: UITextField!
    @IBOutlet weak var eventStartDate: UITextField!
    @IBOutlet weak var eventEndDate: UITextField!
    @IBOutlet weak var eventStartTime: UITextField!
    @IBOutlet weak var eventEndTime: UITextField!
    @IBOutlet weak var eventDescription: UITextField!
    
    
    private var datePicker: UIDatePicker?
    
    private var timePicker: UIDatePicker?
    
    var dateFormatter = DateFormatter()
    var contactsList = [contactList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        set parameters for the date picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(CreateEventViewController.dateChanged(datePicker:)), for: .valueChanged)
//        sets the input to bring up the date picker
       eventStartDate.inputView = datePicker
        eventEndDate.inputView = datePicker
        
        
//        set parameters for the time picker
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        timePicker?.addTarget(self, action: #selector(CreateEventViewController.timeChanged(timePicker:)), for: .valueChanged)
        //        sets the input to bring up the date picker
        eventStartTime.inputView = timePicker
        eventEndTime.inputView = timePicker
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateEventViewController.viewTapped(gestureRecognizer:)))
        

        view.addGestureRecognizer(tapGesture)
        
        print(contactsList)
        
    }
    
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker: UIDatePicker){
        dateFormatter.dateFormat = "yyyy-MM-dd"
       
        if eventStartDate.isFirstResponder {
        
        eventStartDate.text = dateFormatter.string(from: datePicker.date)
            print(dateFormatter.string(from: datePicker.date))
            view.endEditing(true)}
        
        if eventEndDate.isFirstResponder{
            
            eventEndDate.text = dateFormatter.string(from: datePicker.date)
            print(dateFormatter.string(from: datePicker.date))
            view.endEditing(true)}
    else{
    
        }}
    
    @objc func timeChanged(timePicker: UIDatePicker){
        dateFormatter.dateFormat = "HH:mm"
        if eventStartTime.isFirstResponder{
        eventStartTime.text = dateFormatter.string(from: timePicker.date)
            view.endEditing(true)}
        
        if eventEndTime.isFirstResponder{
            eventEndTime.text = dateFormatter.string(from: timePicker.date)
            view.endEditing(true)}
        
        else{
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "createEventSelected"
        {
            let vc = segue.destination as? ViewController
            vc?.contactsList = contactsList
            vc?.eventLocation = eventLocation.text!
            vc?.startDateInput = eventStartDate.text!
            vc?.endDateInput = eventEndDate.text!
            vc?.startTimeInput = eventStartTime.text!
            vc?.endTimeInput = eventEndTime.text!
            vc?.eventDescription = eventDescription.text!
            vc?.addEventToEventStore {
                print("Event Added")
            }
            
        }
    }
    
}
