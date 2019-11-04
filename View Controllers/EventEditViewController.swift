//
//  EventEditViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 09/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import DLRadioButton

var inviteesNames = Array<String>()
var inviteesUserIDs = Array<String>()
var inviteesNamesNew = Array<String>()
var deletedInviteeNames = Array<String>()
var deletedUserIDs = Array<String>()
var deletedNonUserInviteeNames = Array<String>()

class EventEditViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, CellSubclassDelegate {

    
    var dateFormatter = DateFormatter()
    var dateFormatterTime = DateFormatter()
    private var timePicker: UIDatePicker?
    private var datePicker: UIDatePicker?
    var dateFormatterDay = DateFormatter()
    var dateFormatterString = DateFormatter()
    
    var combinedInviteesNames = inviteesNames + nonUserInviteeNames + inviteesNamesNew

    //Zubair: Please use naming convention for IBOutlets I have mentioned
    @IBOutlet var eventTitle: UITextField!
    
    
    @IBOutlet var eventLoction: UITextField!
    
    @IBOutlet var eventStartTime: UITextField!
    
    
    @IBOutlet var eventEndTime: UITextField!
    
    
    @IBOutlet var eventStartDate: UITextField!
    
    @IBOutlet var eventEndDate: UITextField!
    
    
    @IBOutlet var invitees: UITableView!

    @IBOutlet weak var mondayButton: DLRadioButton!
    
    @IBOutlet weak var tuesdayButton: DLRadioButton!
    
    @IBOutlet weak var wednesdayButton: DLRadioButton!
    
    
    @IBOutlet weak var thursdayButton: DLRadioButton!
    
    
    @IBOutlet weak var fridayButton: DLRadioButton!
    
    @IBOutlet weak var saturdayButton: DLRadioButton!
    
    
    @IBOutlet weak var sundayButton: DLRadioButton!
    
    
    
    @IBAction func deleteEventPressed(_ sender: UIButton) {

        let alert = UIAlertController(title: "Delete event", message: "Are you sure you would like to delete the event? (this can't be undone)", preferredStyle: UIAlertController.Style.alert)
        
    
       alert.addAction(UIAlertAction(title: "NO", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: { action in
            
            print("User yes on the event delete")
            
            self.deleteEventStore(eventID: eventIDChosen)
            self.deleteEventRequest(eventID: eventIDChosen)
            self.deleteTemporaryUserEventStore(eventID: eventIDChosen)
            self.deleteRealTimeDatabaseEventInfo(eventID: eventIDChosen)
            self.deleteRealTimeDatabaseUserEventLink(eventID: eventIDChosen)
            
            self.performSegue(withIdentifier: "saveSelected", sender: Any.self)
  
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let navLabel = UILabel()
        let navTitle = NSMutableAttributedString(string: "Circle",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25),NSAttributedString.Key.foregroundColor: UIColor.black])
        
        navTitle.append(NSMutableAttributedString(string: "it",
                                                  attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 30),NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        navLabel.attributedText = navTitle
        
        //        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.navigationItem.titleView = navLabel
        
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor.black
        
//        setup the time picker
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        createTimePicker()
        
//        setup the date picker
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        createDatePicker()
        dateFormatterString.dateFormat = "yyyy-MM-dd"
        dateFormatterString.locale = Locale(identifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "dd MMM YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
//        reset the deleted arrays
        
        deletedInviteeNames.removeAll()
        deletedNonUserInviteeNames.removeAll()
        deletedUserIDs.removeAll()
    
        
//        setup tableview
        invitees.delegate = self
        invitees.dataSource = self
        self.invitees.separatorStyle = UITableViewCell.SeparatorStyle.none
        

        print("combinedInviteesNames \(combinedInviteesNames)")
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        //
        eventTitle.text = eventResultsArrayDetails[2][1] as? String
        eventLoction.text = eventResultsArrayDetails[1][1] as? String
        eventStartTime.text = convertToLocalTime(inputTime: (eventResultsArrayDetails[6][0] as? String)!)
        eventEndTime.text = convertToLocalTime(inputTime:(eventResultsArrayDetails[7][0] as? String)!)
        eventStartDate.text = convertToDisplayDate(inputDate: (eventResultsArrayDetails[4][0] as? String)!)
        eventEndDate.text = convertToDisplayDate(inputDate:(eventResultsArrayDetails[5][0] as? String)!)
        
        
        //Zubair: Please use custom classes if this is used at multiple places
        let borderColour = UIColor(red: 250, green: 250, blue: 250)
        eventTitle.layer.borderColor = borderColour.cgColor
        eventTitle.layer.borderWidth = 1.0
        eventLoction.layer.borderColor = borderColour.cgColor
        eventLoction.layer.borderWidth = 1.0
        eventStartTime.layer.borderColor = borderColour.cgColor
        eventStartTime.layer.borderWidth = 1.0
        eventEndTime.layer.borderColor = borderColour.cgColor
        eventEndTime.layer.borderWidth = 1.0
        eventEndDate.layer.borderColor = borderColour.cgColor
        eventEndDate.layer.borderWidth = 1.0
        eventStartDate.layer.borderColor = borderColour.cgColor
        eventStartDate.layer.borderWidth = 1.0
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveSelected))
        
//        setup radio buttons
        
        self.mondayButton.isMultipleSelectionEnabled = true;
        self.tuesdayButton.isMultipleSelectionEnabled = true;
        self.wednesdayButton.isMultipleSelectionEnabled = true;
        self.thursdayButton.isMultipleSelectionEnabled = true;
        self.fridayButton.isMultipleSelectionEnabled = true;
        self.saturdayButton.isMultipleSelectionEnabled = true;
        self.sundayButton.isMultipleSelectionEnabled = true;
        setRatioButons()
        
        //Zubair: Again, use functions. viewDidLoad is around 100 lines and can easily be reduced
    }
    
    
//    set the rabio buttons status
    
    func setRatioButons(){
        
     let weekDayArray = eventResultsArrayDetails[9][0] as! [Int]
        print("weekDayArray \(weekDayArray)")
        
        let sunday = weekDayArray[0]
        let monday = weekDayArray[1]
        let tuesday = weekDayArray[2]
        let wednesday = weekDayArray[3]
        let thursday = weekDayArray[4]
        let friday = weekDayArray[5]
        let saturday = weekDayArray[6]
        
        if sunday != 10{
            sundayButton.isSelected = true
        }
        if monday != 10{
            mondayButton.isSelected = true
        }
        if tuesday != 10{
            tuesdayButton.isSelected = true
        }
        if wednesday != 10{
            wednesdayButton.isSelected = true
        }
        if thursday != 10{
            thursdayButton.isSelected = true
        }
        if friday != 10{
            fridayButton.isSelected = true
        }
        if saturday != 10{
            saturdayButton.isSelected = true
        }
        
        
    }

    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @objc func saveSelected() {
        //the user selected to save the event
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        print("eventEndTime: \(eventEndTime.text ?? "")")
        print("eventStartTime: \(eventStartTime.text ?? "")")
        print("eventEndDate: \(eventEndDate.text ?? "")")
        print("eventStartDate: \(eventStartDate.text ?? "")")
         
        
        if eventTitle.text == "" {
            
            //Zubair: As I said earlier, if you create a custom class/extension for MBProgressHUD, it would save a lot of re-writing of code
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add an event title"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
        else if eventStartDate.text == "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add an event start date"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
       else if eventEndDate.text == "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add an event end date"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
        else if eventStartTime.text == "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add an event start time"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
       else if eventEndTime.text == "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add an event end time"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
            
       else if mondayButton.isSelected ==  false && tuesdayButton.isSelected ==  false && wednesdayButton.isSelected ==  false && thursdayButton.isSelected ==  false && fridayButton.isSelected ==  false && saturdayButton.isSelected ==  false && sundayButton.isSelected ==  false{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please select at least one day of the week"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
            
       else if dateFormatter.date(from: eventEndDate.text!)!  < dateFormatter.date(from: eventStartDate.text!)! {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Start date must be before end date"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
         }
            
       else if dateFormatterTime.date(from: eventEndTime.text!)! < dateFormatterTime.date(from: eventStartTime.text!)!{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Start time must be before start time"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
            }
            
        else {
            
            daysOfTheWeekNewEvent.removeAll()
            
            //            create the event days of the week array
            
            if sundayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(0, at: 0)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 0)
            }
            if mondayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(1, at: 1)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 1)
            }
            if tuesdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(2, at: 2)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 2)
            }
            if wednesdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(3, at: 3)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 3)
            }
            if thursdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(4, at: 4)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 4)
            }
            if fridayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(5, at: 5)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 5)
            }
            if saturdayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(6, at: 6)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 6)
            }
            print("daysOfTheWeekNewEvent: \(daysOfTheWeekNewEvent)")
            
//            convert the dates into the correct format
            
            let dateFormatterInput = DateFormatter()
            
            dateFormatterInput.dateFormat = "yyyy-MM-dd"
            dateFormatterInput.locale = Locale(identifier: "en_US_POSIX")
            
            let startDateInputDates = dateFormatter.date(from: eventStartDate.text!)
            let endDateInputDates = dateFormatter.date(from: eventEndDate.text!)
            let startDateInputString = dateFormatterInput.string(from: startDateInputDates!)
            let endDateInputString = dateFormatterInput.string(from: endDateInputDates!)

                
            getStartAndEndDates3(startDate: startDateInputString, endDate: endDateInputString, startTime: eventStartTime.text!, endTime: eventEndTime.text!, daysOfTheWeek: daysOfTheWeekNewEvent){ (startDates,endDates) in
            
//            commit the updated event information to the database
            
            let documentID = eventResultsArrayDetails[3][1] as? String
                //Zubair: Again you are using firebase code within UIViewController. It should be done within a Firebase Manager class.
                //Zubair: Use constants rather than hard coded strings
                dbStore.collection("eventRequests").document(documentID!).setData(["eventDescription" : self.eventTitle.text!, "location" : self.eventLoction.text!, "endTimeInput" :self.convertToGMT(inputTime: self.eventEndTime.text!), "startTimeInput" :self.convertToGMT(inputTime: self.eventStartTime.text!), "endDateInput" : self.convertToStringDate(inputDate: self.eventEndDate.text!), "startDateInput" : self.convertToStringDate(inputDate:self.eventStartDate.text!), "daysOfTheWeek" : daysOfTheWeekNewEvent, "startDates": startDates, "endDates": endDates], merge: true)
            
//            updated the realtime database
            
            let rRef = Database.database().reference()
            
                rRef.child("events/\(eventCreationID)/eventDescription").setValue(self.eventTitle.text!)
                
            }
// checks to see whethe the user has made any changes to the event timing
        
            if eventStartTime.text == convertToLocalTime(inputTime: (eventResultsArrayDetails[6][1] as? String)!) &&
            eventEndTime.text == convertToLocalTime(inputTime:(eventResultsArrayDetails[7][1] as? String)!) &&
            eventStartDate.text == convertToDisplayDate(inputDate: (eventResultsArrayDetails[4][1] as? String)!) &&
                eventEndDate.text == convertToDisplayDate(inputDate:(eventResultsArrayDetails[5][1] as? String)!) && daysOfTheWeek == daysOfTheWeekNewEvent {
  
            print("event updates committed")
            
                let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
                loadingNotification.label.text = "Event Information Updated"
                loadingNotification.customView = UIImageView(image: UIImage(named: "Available"))
                loadingNotification.mode = MBProgressHUDMode.customView
                loadingNotification.hide(animated: true, afterDelay: 1)
        }
            else{
                
                //            removes any availability arrays that have already been saved down
                print("event timmings have changed")
                deleteEventStoreAvailability(eventID: eventIDChosen)
                
                //Zubair: Use custom object or extension
                let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
                loadingNotification.label.text = "Event Information Updated - availability data reset"
                loadingNotification.label.adjustsFontSizeToFitWidth = true
                loadingNotification.customView = UIImageView(image: UIImage(named: "Available"))
                loadingNotification.mode = MBProgressHUDMode.customView
                loadingNotification.hide(animated: true, afterDelay: 1)
                
            }
        
        print("contactsSelected: \(contactsSelected)")
        
//        We need to first check if the user removed an invitees, the users deleted names and user IDs are held in two arrays
        
        if deletedUserIDs.count == 0{
            
            print("user didnt delete any invitees")
            
        }
        else{
//            we now need to delete the users from the eventRequest and userEventStore
            
//            deletes the userEventStore
         deleteUserEventLinkArray(userID: deletedUserIDs, eventID: eventIDChosen)
            
         addUserIDsToEventRequests(userIDs: inviteesUserIDs, currentUserID: [""], existingUserIDs: [""], eventID: eventIDChosen, addCurrentUser: false)
   
        }
            
            if deletedNonUserInviteeNames.count == 0{
               
              print("no non users deleted")
                
            }
            else{
                
                deleteNonUsers(eventID: eventIDChosen, userNames: deletedNonUserInviteeNames)
            }

//        checks to see if the user has added any invitees
        if contactsSelected.count == 0{
            print("no new invitees selected")
            
        }
        else{
            print("New invitees selected")
            
            var selectedPhoneNumbers = [String]()
            var selectedNames = [String]()
            
            selectedPhoneNumbers = getSelectedContactsPhoneNumbers2().phoneNumbers
            selectedNames = getSelectedContactsPhoneNumbers2().names
                

            
            createUserIDArrays(phoneNumbers: selectedPhoneNumbers, names: selectedNames) { (nonExistentArray, existentArray, userNameArray, nonExistentNameArray) in
                
                print("nonExistentArray \(nonExistentArray)")
                print("existentArray \(existentArray)")
                
//           adds the non users to the database
                self.addNonExistingUsers2(phoneNumbers: nonExistentArray, eventID: eventIDChosen, names: nonExistentNameArray)
                
//            Adds the user event link to the userEventStore
                
                self.userEventLinkArray(userID: existentArray, userName: userNameArray, eventID: eventIDChosen)

                self.addUserIDsToEventRequests(userIDs: existentArray, currentUserID: [""], existingUserIDs: inviteesUserIDs, eventID: eventIDChosen, addCurrentUser: false)
                
                print("new users added")
                
//            remove the selected contacts from the array
                
             contactsSelected.removeAll()
                inviteesNamesNew.removeAll()
                selectedContacts.removeAll()
                
                }
   
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `1.0` to the desired number of seconds.
            self.performSegue(withIdentifier: "saveSelected", sender: Any.self)
        }
        }
        
//     save selected end
    }

    func createTimePicker(){
        //        assign date picker to our text input
        
        eventStartTime.inputView = timePicker
        eventEndTime.inputView = timePicker
        
        
        //        add a toolbar to the datepicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        
        //        add a done button to the toolbar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedTime))
        
        
        //        Adds space to the left of the done button, pushing the button to the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        
        eventStartTime.inputAccessoryView = toolBar
        eventEndTime.inputAccessoryView = toolBar
    }
    
    
    @objc func doneClickedTime(){
        dateFormatter.dateFormat = "HH:mm"
        if eventStartTime.isFirstResponder{
            
            eventStartTime.text = dateFormatter.string(from: timePicker!.date)
            self.view.endEditing(true)
        }
        
        if eventEndTime.isFirstResponder{
            
            eventEndTime.text = dateFormatter.string(from: timePicker!.date)
            self.view.endEditing(true)
            
        }
    }
    

    func createDatePicker(){
        //        assign date picker to our text input
        
        eventStartDate.inputView = datePicker
        eventEndDate.inputView = datePicker
        
        
        //        add a toolbar to the datepicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        
        //        add a done button to the toolbar
        
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedDate))
        
        //    moves the done button to the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexSpace, doneButton], animated: false)
        
        eventStartDate.inputAccessoryView = toolBar
        eventEndDate.inputAccessoryView = toolBar
    }
    
    
    @objc func doneClickedDate(){
        dateFormatter.dateFormat = "dd MMM YYYY"
        if eventStartDate.isFirstResponder{
            
            eventStartDate.text = dateFormatter.string(from: datePicker!.date)
            newEventStartDate = dateFormatterString.string(from: datePicker!.date)
            self.view.endEditing(true)
        }
        
        if eventEndDate.isFirstResponder{
            
            eventEndDate.text = dateFormatter.string(from: datePicker!.date)
            newEventEndDate = dateFormatterString.string(from: datePicker!.date)
            self.view.endEditing(true)
            
        }
        
    }
    
    
    
    //Zubair: Please write delegate and datasource methods within extensions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var numberOfRows = Int()
    
        
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
        numberOfRows = combinedInvitees.count
        
        print("numberOfRows \(numberOfRows)")
    
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = invitees.dequeueReusableCell(withIdentifier: "inviteesCell", for: indexPath) as? EditTableViewCell
        else{
            fatalError("could not deque edit cell")
        }
        
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
 
        
        cell.delegate = self
        cell.cellLabel.text = combinedInvitees[indexPath.row]
        
        //Zubair: Configuration code shouldn't be within cellForRowAtIndexPath
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.clipsToBounds = true
            
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            return 40
        
        ;//Choose your custom row height
    }
    

    
//    the user selecte the delete button in the tableview
    @objc func deleteButtonPressed(indexPath: IndexPath){
        print("delete button pressed")
      
        
        
    }
    
    
    func buttonTapped(cell: EditTableViewCell) {
        guard let indexPath = self.invitees.indexPath(for: cell) else {
            // Note, this shouldn't happen - how did the user tap on a button that wasn't on screen?
            return
        }
        
        //  Do whatever you need to do with the indexPath
        
        print("Button tapped on row \(indexPath.row)")
        
//        we remove the users name and ID from our array
        
        let originalInvitees = inviteesNames.count - 1
        print("originalInvitees: \(originalInvitees)")
        let nonUserInvitees = nonUserInviteeNames.count + originalInvitees
        print("nonUserInvitees: \(nonUserInvitees)")
        let combinedInvitees = inviteesNames + nonUserInviteeNames + inviteesNamesNew
        print("combinedInvitees: \(combinedInvitees)")
        
        if indexPath.row <= originalInvitees {
        
        
        deletedInviteeNames.append(inviteesNames[indexPath.row])
        print("deleted invitee: \(inviteesNames[indexPath.row])")

            
        deletedUserIDs.append(inviteesNamesLocation[indexPath.row])
            print("deletedUserIDs: \(deletedUserIDs)")
            
        inviteesNames.remove(at: indexPath.row)
            
        let indexOfItem = inviteesUserIDs.index(of: inviteesNamesLocation[indexPath.row])!
        inviteesUserIDs.remove(at: indexOfItem)
        inviteesNamesLocation.remove(at: indexPath.row)
       
            
        print("new invitee names \(inviteesNames)")
        print("new invitee uid \(inviteesUserIDs)")
        invitees.reloadData()
            
            
//        remove the selected status of the user
            
            
            
        }
        if originalInvitees < indexPath.row && indexPath.row  <= nonUserInvitees{
            
            
            deletedNonUserInviteeNames.append(combinedInvitees[indexPath.row])
            print("deletedNonUserInviteeNames: \(deletedNonUserInviteeNames)")
            let indexOfItem = nonUserInviteeNames.index(of: combinedInvitees[indexPath.row])!
            nonUserInviteeNames.remove(at: indexOfItem)
            invitees.reloadData()
            
        }
        
        if indexPath.row > nonUserInvitees{
            
          inviteesNamesNew.remove(at: indexPath.row - (nonUserInvitees + 1))
            contactsSelected.remove(at: indexPath.row - (nonUserInvitees + 1))
            invitees.reloadData()
            
        }
        
        
    }
    
  
    @IBAction func addUsersTapped(_ sender: UIButton) {
        
//        we remove the contacts to reset the selected list each time we add new people
        contactsSorted.removeAll()
        contactsFiltered.removeAll()
        
        performSegue(withIdentifier: "addUsersSelected", sender: Any.self)
 
        
    }
    
    
    //    MARK: Functions for deleting a crated event
    func deleteEventRequest(eventID: String){
        let docRefEventRequest = dbStore.collection("eventRequests")
        
        docRefEventRequest.document(eventID).delete()
    }
    
    func deleteEventStore(eventID: String){
        
        //Zubair: All firebase code should be written within a manager class
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).updateData(["userAvailability" : FieldValue.delete()]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    docRefUserEventStore.document(documentID).delete()
                }
            }
        }
    }
    
    func deleteTemporaryUserEventStore(eventID: String){
        
        let docRefUserEventStore = dbStore.collection("temporaryUserEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).delete(){ err in
                        if let err = err {
                            print("Error deleting document: \(err)")
                        } else {
                            print("Document successfully deleted")
                        }
                    }
                    
                    docRefUserEventStore.document(documentID).delete()
                }
            }
        }
    }
    
    func deleteEventStoreAvailability(eventID: String){
        
        let docRefUserEventStore = dbStore.collection("userEventStore")
        
        docRefUserEventStore.whereField("eventID", isEqualTo: eventID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")}
                
            else{
                for document in querySnapshot!.documents{
                    
                    let documentID = document.documentID
                    
                    docRefUserEventStore.document(documentID).updateData(["userAvailability" : FieldValue.delete()]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                    docRefUserEventStore.document(documentID).updateData(["chosenDate" : FieldValue.delete()]){ err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                    
                }
            }
        }
    }
    
//    section for deleting the realtime database entries
    
    
    func deleteRealTimeDatabaseEventInfo(eventID: String){
    let ref = Database.database().reference()
        
        ref.child("events/\(eventID)").removeValue()
   
    }
    
    func deleteRealTimeDatabaseUserEventLink(eventID: String){
        let ref = Database.database().reference()
        ref.child("userEventLink/\(user!)/\(eventID)").removeValue()
        
    }
    
    
    
//    this is used to run the getUsersNames when the user hits back, reloading the tableview with the current users names, even when they have removed some, but not saved them
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            let vc = ViewController2()
            vc.getUsersNames()
        }
    }
    
    
    //        move the view up when the keyboard is active
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}


