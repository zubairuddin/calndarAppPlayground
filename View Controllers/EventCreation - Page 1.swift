//
//  EventCreation - Page 1.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 22/07/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import DLRadioButton
import MBProgressHUD
import Firebase
import AMPopTip
import Instructions

var newEventDescription = String()
var newEventLocation = String()
var newEventStartTime = "06:00"
var newEventEndTime = "06:00"
var newEventStartTimeLocal = "06:00"
var newEventEndTimeLocal = "06:00"
var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
var circleColour = UIColor(red: 0, green: 176, blue: 156)


class EventCreation___Page_1: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    
    /// Get distance from top, based on status bar and navigation
    public var topDistance : CGFloat{
         get{
             if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                 return 0
             }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                return barHeight + statusBarHeight
             }
         }
    }


    
    var dateFormatter = DateFormatter()
    var dateFormatterTime = DateFormatter()
    private var timePicker: UIDatePicker?
    let coachMarksController = CoachMarksController()
    let popTip = PopTip()
    
//    selection choices for the default events
    var userEventChoices = ["Dinner","Drinks","Lunch","Coffee","Party","Custom"]
    var userEventChoicesLocations = ["Restaurant","Bar","Restaurant","Cafe","My Place","Anywhere"]
    var userEventChoicesStartTime = ["19:00","20:00","12:00","10:00","19:00","10:00"]
    var userEventChoicesEndTime = ["21:00","23:00","13:30","11:00","23:59","16:00"]
    var userEventChoicesimages = ["Dinner500","Drinks500","Lunch500","Coffee500","Party500","Meeting"]
//    var userEventChoicesimages = ["RP - Dinner","RP - Drinks","Lunch","RP - Coffee","Meeting"]
    
    
    @IBOutlet weak var collectionViewEventType: UICollectionView!
    
    
    @IBOutlet weak var quickCreate: UILabel!
    

    
    @IBAction func eventLocationInformationButton(_ sender: UIButton) {
      
        popTip.bubbleColor = circleColour
        
        popTip.show(text: "Location shown to your invited friends. Example: The local pub, Nandos Clapham Common", direction: .right, maxWidth: 200, in: view, from: sender.frame)
        
    }
    
    @IBAction func eventDurationInformationButton(_ sender: UIButton) {
     
        popTip.bubbleColor = circleColour
        
        popTip.show(text: "What time of day is your event? Example: 18:00 - 20:00", direction: .right, maxWidth: 200, in: view, from: sender.frame)
        
    }
    
    
    
    @IBAction func eventTitleInformationButton(_ sender: UIButton) {
        
        popTip.bubbleColor = circleColour
        
        popTip.show(text: "Title shown to your invitees. Example: Dinner with Study group", direction: .right, maxWidth: 200, in: view, from: sender.frame)
    }
    
    
 
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var eventDescription: UITextField!
    
    @IBOutlet weak var eventLocation: UITextField!
    
    @IBOutlet weak var eventStartTime: UITextField!
    
    @IBOutlet weak var eventEndTime: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Set the navigation bar
        self.title = "Create Event"
        navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 176, blue: 156)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20)]
        navigationController?.navigationBar.tintColor = UIColor.black
        
        //        restrict the rotation of the device to portrait
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        
//        set the background colour
        self.view.backgroundColor = UIColor(red: 253, green: 253, blue: 253)
        
        
//        move the view up when the keyboard is active
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        set the text field border colour
        let borderColour = UIColor(red: 250, green: 250, blue: 250)
        eventDescription.layer.borderColor = borderColour.cgColor
        eventDescription.layer.borderWidth = 1.0
        eventLocation.layer.borderColor = borderColour.cgColor
        eventLocation.layer.borderWidth = 1.0
        eventStartTime.layer.borderColor = borderColour.cgColor
        eventStartTime.layer.borderWidth = 1.0
        eventEndTime.layer.borderColor = borderColour.cgColor
        eventEndTime.layer.borderWidth = 1.0
        

        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextSelected))
        
      
 
        
        dateFormatterTime.dateFormat = "HH:mm"
        dateFormatter.dateFormat = "HH:mm"
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        createTimePicker()
        
        
//        set up the collection view
        
        collectionViewEventType.dataSource = self
        collectionViewEventType.delegate = self
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
        
//        end of view did load
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @objc func nextSelected(){
        
        dateFormatterTime.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if eventDescription.text == "" {
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add an event title"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
            
            
            
        else if eventStartTime.text ==  ""{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add a start time"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)

            
        }
            
        else if eventEndTime.text ==  ""{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add a end time"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
            
            //            let date3 = dateFormatterTime.date(from: eventEndTime.text!)!
            //            let date4 = dateFormatterTime.date(from: eventStartTime.text!)!
            
        }
            
        else if dateFormatterTime.date(from: eventEndTime.text!)! <= dateFormatterTime.date(from: eventStartTime.text!)!{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Start time must be before start time"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 1)
            
        }
            
        else{
            print(eventStartTime.text!)
            
            let dateStartDate = dateFormatter.date(from: eventStartTime.text!)
            let adjStartTimeDate = dateStartDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
            let adjStartTimeString = dateFormatter.string(from: adjStartTimeDate)
            
            let dateEndDate = dateFormatter.date(from: eventEndTime.text!)
            let adjEndTimeDate = dateEndDate!.addingTimeInterval(TimeInterval(-secondsFromGMT))
            let adjEndTimeString = dateFormatter.string(from: adjEndTimeDate)
            
            newEventStartTimeLocal = eventStartTime.text!
            newEventEndTimeLocal = eventEndTime.text!
            newEventStartTime = adjStartTimeString
            newEventEndTime = adjEndTimeString
            newEventDescription = eventDescription.text!
            newEventLocation = eventLocation.text!
            
            performSegue(withIdentifier: "eventCreationPage1Complete", sender: Any.self)
        }
        
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
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numberOfColumns = userEventChoices.count
        print("numberOfColumns: \(numberOfColumns)")
        
        return numberOfColumns
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionViewEventType.dequeueReusableCell(withReuseIdentifier: "collectionCellCreateEvent", for: indexPath) as? CollectionViewCellCreateEvent
            else{
                fatalError("failed to create user created events cell")
        }
        
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.clear.cgColor
        cell.layer.masksToBounds = true
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        cell.backgroundColor = UIColor.white
        
        
        cell.collectionViewCellImage.image = UIImage(named: userEventChoicesimages[indexPath.row])
        
        cell.collectionViewLabel.text = userEventChoices[indexPath.row]
        
        
        
        return cell
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let sections = 1
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        what to do once the user selects a cell in the collectionview
        
        print("user selected row: \(indexPath.row)")
        
     eventDescription.text = userEventChoices[indexPath.row]
    eventLocation.text = userEventChoicesLocations[indexPath.row]
        eventStartTime.text = userEventChoicesStartTime[indexPath.row]
        eventEndTime.text = userEventChoicesEndTime[indexPath.row]
        scrollView.setContentOffset(CGPoint(x: 0, y: 300), animated: true)
        
        
    }
    
    
    //    MARK: - three mandatory methods for choach tips
            
            func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
                
                let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                
                let hintLabels = ["Creating your first event - we'll guide you through it","Choose from the most popular event types","Or customise the event details below"]
                
                let nextlabels = ["OK","OK","OK"]
                
                coachViews.bodyView.hintLabel.text = hintLabels[index]
                
                coachViews.bodyView.nextLabel.text = nextlabels[index]
    //            coachViews.bodyView.nextLabel.isEnabled = false
                
                return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                
            }
            

        //    Defines where the coachmark will appear
            var pointOfInterest = UIView()
            
            func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                
                
                let hintPositions = [CGRect(x: screenWidth/2 , y: 100, width: 1, height: 1),CGRect(x: screenWidth/2 - 150, y: topDistance + 50, width: 300, height: 425),CGRect(x: 0 , y: topDistance + 500, width: screenWidth, height: 30)]
                pointOfInterest.frame = hintPositions[index]
                
                
                return coachMarksController.helper.makeCoachMark(for: pointOfInterest)
            }
            
            
            
            
        //    The number of coach marks we wish to display
            func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
                return 3
            }
        
    //    When a coach mark appears
        func coachMarksController(_ coachMarksController: CoachMarksController, willShow coachMark: CoachMark, at index: Int){
            
            print("Coach Index appeared \(index)")
            
            print("Coach Index disappeared \(index)")
            
            

            
        }
        
    //    when a coach mark dissapears
        func coachMarksController(_ coachMarksController: CoachMarksController, willHide coachMark: CoachMark, at index: Int){
            

            
            
        }


            
            //    The coach marks must be called from the viewDidAppear and not the ViewDidLoad.
            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                            
                            
                //            TO ADD - check to see if we are on the new page
                
                
                //            positions on the screen for each hint
                
                let firstEventCoachMarksCount = UserDefaults.standard.integer(forKey: "firstEventCoachMarksCount")
                let coachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
                
                print("firstEventCoachMarksCount \(firstEventCoachMarksCount)")
                
                
                if firstEventCoachMarksCount <= 1 || coachMarksPermenant == true{
                
                coachMarksController.start(in: .window(over: self))
                    
                    UserDefaults.standard.set(firstEventCoachMarksCount + 1, forKey: "firstEventCoachMarksCount")
                    
                }
                else{
                    
                }
            }
        
        //    The view coachmarks should be removed once the view is removed
        override func viewWillDisappear( _ animated: Bool) {
            super.viewWillDisappear(animated)

            coachMarksController.stop(immediately: true)
        }
    
    
    
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

extension EventCreation___Page_1 : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 125)
    }
}

