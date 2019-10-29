//
//  EventCreation - Page 2.swift
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

var newEventStartDate = String()
var newEventEndDate = String()

class EventCreation___Page_2: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
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
    

    private var datePicker: UIDatePicker?
    var dateFormatter = DateFormatter()
    var dateFormattertz = DateFormatter()
    var dateFormatterString = DateFormatter()
    var dateFormatterInput = DateFormatter()
    var dateFormatterInputString = DateFormatter()
    let popTip = PopTip()
    var potentialDates = Array<String>()
    var timePeriods = ["1 week","2 weeks","1 month","2 months","3 months", "Custom"]
    var timePeriodImages = ["1w500","2w500","1m500","2m500","3m500","custom500"]
    var timePeriodsAdditionType = [Calendar.Component.day,Calendar.Component.day,Calendar.Component.month,Calendar.Component.month,Calendar.Component.month,Calendar.Component.day]
    var timePeriodsAddition = [7,14,1,2,3,7]
    let coachMarksController = CoachMarksController()
    
    
    
    @IBOutlet weak var eventStartDate: UITextField!
    
    @IBOutlet weak var eventEndDate: UITextField!
    
    
    @IBOutlet weak var mondayButton: DLRadioButton!
    
    
    @IBOutlet weak var tuesdayButton: DLRadioButton!
    
    @IBOutlet weak var wednesdayButton: DLRadioButton!
    
    @IBOutlet weak var thursdayButton: DLRadioButton!
    
    @IBOutlet weak var fridayButton: DLRadioButton!
    
    @IBOutlet weak var saturdayButton: DLRadioButton!
    
    @IBOutlet weak var sundayButton: DLRadioButton!
    
    
    @IBOutlet weak var anyDayButton: DLRadioButton!
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    @IBOutlet weak var dateRangeCollectionView: UICollectionView!
    
    
    
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        
    updateProposedDatesTable()
        
    }
    

    @objc func nextSelected(){
        
        
        if eventStartDate.text ==  ""{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add a start date"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 2)
            
        }
            
       else if eventEndDate.text ==  ""{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please add a end date"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 2)
            
        }
            
        else if dateFormatterString.date(from: newEventStartDate)!  > dateFormatterString.date(from: newEventEndDate)! {

            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Start date must be before end date"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 2)
        }
        
        else if mondayButton.isSelected ==  false && tuesdayButton.isSelected ==  false && wednesdayButton.isSelected ==  false && thursdayButton.isSelected ==  false && fridayButton.isSelected ==  false && saturdayButton.isSelected ==  false && sundayButton.isSelected ==  false && anyDayButton.isSelected ==  false{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "Please select at least one day of the week or the any day button"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 2)
        }
        else if updateProposedDatesTable() == false{
            
            let loadingNotification = MBProgressHUD.showAdded(to: view, animated: false)
            loadingNotification.label.text = "The days of the week chosen are not contained within the dates chosen, select 'Any' day of the week"
            loadingNotification.label.adjustsFontSizeToFitWidth = true
            loadingNotification.label.numberOfLines = 2
            loadingNotification.customView = UIImageView(image: UIImage(named: "Unavailable"))
            loadingNotification.mode = MBProgressHUDMode.customView
            loadingNotification.hide(animated: true, afterDelay: 2)
            
            
        }
        
        else{
            
            print("\(dateFormatterString.date(from: newEventStartDate)!) + \(dateFormatterString.date(from: newEventEndDate)!)")
            
            daysOfTheWeekNewEvent.removeAll()
            
            if sundayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(0, at: 0)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 0)
            }
            if mondayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(1, at: 1)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 1)
            }
            if tuesdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(2, at: 2)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 2)
            }
            if wednesdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(3, at: 3)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 3)
            }
            if thursdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(4, at: 4)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 4)
            }
            if fridayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(5, at: 5)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 5)
            }
            if saturdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(6, at: 6)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 6)
            }
            
            print("daysOfTheWeekNewEvent: \(daysOfTheWeekNewEvent)")
            

            print("newEventEndDate \(newEventEndDate)")
  
            print("newEventStartDate \(newEventStartDate)")

        
        performSegue(withIdentifier: "eventCreationPage2Complete", sender: Any.self)
        }
        
    }
    
    
    @IBAction func searchPeriodInformationButton(_ sender: UIButton) {
        popTip.bubbleColor = circleColour
        
        popTip.show(text: "When should your event occur? Circleit will search for availability over the period you choose", direction: .down, maxWidth: 200, in: view, from: sender.frame)
    }
    
    
    @IBAction func daysOfTheEventInformationButton(_ sender: UIButton) {
        popTip.bubbleColor = circleColour
        
        popTip.show(text: "Which days of the week could your event occur? Tip: you can pick multiple days", direction: .up, maxWidth: 200, in: view, from: sender.frame)
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Timing"
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
        
        
//        setup the date pickers
        let borderColour = UIColor(red: 250, green: 250, blue: 250)
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        createDatePicker()
        dateFormatterString.dateFormat = "yyyy-MM-dd"
        dateFormatterString.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMM YYYY"
        
        eventStartDate.layer.borderColor = borderColour.cgColor
        eventStartDate.layer.borderWidth = 1.0
        eventEndDate.layer.borderColor = borderColour.cgColor
        eventEndDate.layer.borderWidth = 1.0
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextSelected))
        
//        setup the day picker buttons
        mondayButton.isMultipleSelectionEnabled = true
        tuesdayButton.isMultipleSelectionEnabled = true
        wednesdayButton.isMultipleSelectionEnabled = true
        thursdayButton.isMultipleSelectionEnabled = true
        fridayButton.isMultipleSelectionEnabled = true
        saturdayButton.isMultipleSelectionEnabled = true
        sundayButton.isMultipleSelectionEnabled = true
        anyDayButton.isMultipleSelectionEnabled = true
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
//        setup the tableview
        
//        potentialDatesTableView.delegate = self
//        potentialDatesTableView.dataSource = self
        
        dateRangeCollectionView.dataSource = self
        dateRangeCollectionView.delegate = self
        
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.allowTap = true
        
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        print("view tapped")
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
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    dateFormatterString.locale = Locale(identifier: "en_US_POSIX")
    if eventStartDate.isFirstResponder{
        
        eventStartDate.text = dateFormatter.string(from: datePicker!.date)
        newEventStartDate = dateFormatterString.string(from: datePicker!.date)
        self.view.endEditing(true)
//        updateProposedDatesTable()
    }
    
    if eventEndDate.isFirstResponder{
        
        eventEndDate.text = dateFormatter.string(from: datePicker!.date)
        newEventEndDate = dateFormatterString.string(from: datePicker!.date)
        self.view.endEditing(true)
//        updateProposedDatesTable()
        
    }
    
}
    
    func updateProposedDatesTable() -> Bool{
        daysOfTheWeekNewEvent.removeAll()
        
        var datesReturned = Bool()
        
        if (mondayButton.isSelected ==  false || tuesdayButton.isSelected ==  false || wednesdayButton.isSelected ==  false || thursdayButton.isSelected ==  false || fridayButton.isSelected ==  false || saturdayButton.isSelected ==  false || sundayButton.isSelected ==  false || anyDayButton.isSelected ==  false) && (eventStartDate.text ==  "" || eventEndDate.text ==  ""){
            
            print("no information chosen yet")
        }
        else{
            print("We have enough information, will run the date check")
            
            
            if sundayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(0, at: 0)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 0)
            }
            if mondayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(1, at: 1)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 1)
            }
            if tuesdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(2, at: 2)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 2)
            }
            if wednesdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(3, at: 3)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 3)
            }
            if thursdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(4, at: 4)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 4)
            }
            if fridayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(5, at: 5)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 5)
            }
            if saturdayButton.isSelected == true || anyDayButton.isSelected == true{
                daysOfTheWeekNewEvent.insert(6, at: 6)
            }
            else{
                daysOfTheWeekNewEvent.insert(10, at: 6)
            }
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            dateFormatterInput.dateFormat = "dd MMM yyyy"
            dateFormatterInputString.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatterInput.locale = Locale(identifier: "en_US_POSIX")
            dateFormatterInputString.locale = Locale(identifier: "en_US_POSIX")
            let startDate = dateFormatter.date(from: "\(eventStartDate.text!) 00:00 ")
            let endDate = dateFormatter.date(from: "\(eventEndDate.text!) 00:00 ")
            print("startDate: \(startDate!)")
            print("endDate: \(endDate!)")
            
//            convert the start and end date into the format for the getStartAndEndDates3
            
            let startDateInputDate = dateFormatterInput.date(from: eventStartDate.text!)
            let endDateInputDate = dateFormatterInput.date(from: eventEndDate.text!)
            
            let startDateInputString = dateFormatterInputString.string(from: startDateInputDate!)
            let endDateInputString = dateFormatterInputString.string(from: endDateInputDate!)
            
            getStartAndEndDates3(startDate: startDateInputString, endDate: endDateInputString, startTime: newEventStartTimeLocal, endTime: newEventEndTimeLocal, daysOfTheWeek: daysOfTheWeekNewEvent){(startDates,endDates) in
                
                self.potentialDates = startDates
                
                if startDates.count == 0{
                    
                    datesReturned = false
                    
                    print("No dates returned")
                    
                }
                else{
                    
                    datesReturned = true
                    
                    print("Dates returned")
                    
                }
            
                print("potentialDates: \(self.potentialDates)")
            
//                self.potentialDatesTableView.reloadData()
            
        }}
        
        return datesReturned
        
    }

    
    //Mark: Tableview
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let numberOfRows = potentialDates.count
//        
//        return numberOfRows
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "potentialDatesCell", for: indexPath)
//        
//        dateFormatter.dateFormat = "dd MMM YYYY"
//        
//        dateFormattertz.dateFormat = "yyyy-MM-dd HH:mm z"
//        
//        dateFormattertz.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        let displayDatetz = dateFormattertz.date(from: potentialDates[indexPath.row])!
//        let displayDate = dateFormatter.string(from: displayDatetz)
//
//        cell.textLabel?.text = displayDate
//        
//        return cell
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfRows = timePeriods.count
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = dateRangeCollectionView.dequeueReusableCell(withReuseIdentifier: "timePeriodCell", for: indexPath) as? CollectionViewCellTimePeriod
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
        cell.timePeriodImage.image = UIImage(named: timePeriodImages[indexPath.row])
//        cell.timePeriodLabel.text = timePeriods[indexPath.row]
        cell.timePeriodLabel.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentDate = Date()
        let dateFormatterDisplay = DateFormatter()
        dateFormatterDisplay.dateFormat = "dd MMM YYYY"
        dateFormatterDisplay.locale = Locale(identifier: "en_US_POSIX")
        
        //        what to do once the user selects a cell in the collectionview
        
        print("user selected row: \(indexPath.row)")
        
       let newEndDate = dateInXDays(increment: timePeriodsAddition[indexPath.row], additionType: timePeriodsAdditionType[indexPath.row])
        
        let newEndDateDisplay = dateFormatterDisplay.string(from: newEndDate)
        print("newEndDate: \(newEndDateDisplay)")
        
        eventEndDate.text = newEndDateDisplay
        newEventEndDate = dateFormatterString.string(from: newEndDate)
        
        eventStartDate.text = dateFormatterDisplay.string(from: currentDate)
        newEventStartDate = dateFormatterString.string(from: currentDate)
        
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 300), animated: true)
//        updateProposedDatesTable()
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let sections = 1
        return sections
    }
    
    
        //    MARK: - three mandatory methods for choach tips
                
                func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
                    
                    let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                    
                    let hintLabels = ["When could your event occur? Choose from the list...in the next 1 week, 1 month...","or customise a specific period for your event","And which days of the week could you event occur"]
                    
                    let nextlabels = ["OK","OK","OK"]
                    
                    coachViews.bodyView.hintLabel.text = hintLabels[index]
                    
                    coachViews.bodyView.nextLabel.text = nextlabels[index]
        //            coachViews.bodyView.nextLabel.isEnabled = false
                    
                    return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
                    
                }
                

            //    Defines where the coachmark will appear
                var pointOfInterest = UIView()
                
                func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
                    
                    
                    let hintPositions = [CGRect(x: screenWidth/2 - 150, y: topDistance + 30, width: 300, height: 425),CGRect(x: 0 , y: topDistance + 350, width: screenWidth, height: 100),CGRect(x: 0 , y: topDistance + 540, width: screenWidth, height: 50)]
                    
                    let screenPositions = [CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 300),CGPoint(x: 0, y: 0)]
                    
                    pointOfInterest.frame = hintPositions[index]
                    
                    scrollView.setContentOffset(screenPositions[index], animated: true)
                    
                    
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
                    
                    let firstEventCoachMarksCount2 = UserDefaults.standard.integer(forKey: "firstEventCoachMarksCount2")
                    let coachMarksPermenant = UserDefaults.standard.bool(forKey: "permenantToolTips")
                    
                    print("firstEventCoachMarksCount2 \(firstEventCoachMarksCount2)")
                    
                    
                    if firstEventCoachMarksCount2 <= 1 || coachMarksPermenant == true{
                    
                    coachMarksController.start(in: .window(over: self))
                        
                        UserDefaults.standard.set(firstEventCoachMarksCount2 + 1, forKey: "firstEventCoachMarksCount2")
                        
                    }
                    else{
                        
                    }
                }
            
            //    The view coachmarks should be removed once the view is removed
            override func viewWillDisappear( _ animated: Bool) {
                super.viewWillDisappear(animated)

                coachMarksController.stop(immediately: true)
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

extension EventCreation___Page_2 : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 125, height: 125)
    }
}
