//
//  ContactsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 28/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import ContactsUI


var contactsList = [contactList]()

class ContactsViewController: UITableViewController, UISearchBarDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var searchContacts: UISearchBar!


    
//    property for holding the filtered data
    var filteredData = [contactList]()
    var data = "test"
    
//    this tells the controller we want to  use the same view to display the results as we use to search
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       searchContacts.delegate = self
        fetchContacts()
        navigationController?.delegate = self

        
    }
    
    
    
//    this function is used to fetch the contacts
    func fetchContacts(){
    print("Attempting to fetch the contacts")
        
    let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to get access",error)
                return
            }
            if granted{
                print("Acccess Granted")
                
//                Need to request access to both the given name and the family name and the phone number, each has its own key
                let keys = [CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
            
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopPointerEnumerating) in
//                        print(contact.givenName)
                    
                        contactsList.append(contactList(name: contact.givenName + " " + contact.familyName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "", selectedContact: false))
                    
                        
//                        print(self.contactsList)
                    
                        
                  self.tableView.reloadData()  })
                    
                } catch let error{
                    print("Failed to enumerate contacts:",error)
                }
            }
            else{
                print("Access Denied")
                
                
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return contactsList.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)

        let item: contactList
    

             item = contactsList[indexPath.row]
//            print(item)
//            print(contactsList)
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.phoneNumber
        
        if item.selectedContact == true {
            cell.accessoryType = .checkmark
            
        } else{
            cell.accessoryType = .none
        }
    
        return cell
//        print(item.selectedContact)

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //        check to see if there already exist a check mark, if there is remove it, if there isnt add it
        //        sets the done property on the item in the array to the opposite of what it is now
        contactsList[indexPath.row].selectedContact = !contactsList[indexPath.row].selectedContact
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
  
    }

    
    
    // This method updates filteredData based on the text in the Search Box
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        // When there is no text, filteredData is the same as the original data
//        // When user has entered text into the search box
//        // Use the filter method to iterate over all items in the data array
//        // For each item, return true if the item should be included and false if the
//        // item should NOT be included
//        if searchText.isEmpty {
//            filteredData = contactsList
//        }else{
//            filteredData = contactsList.filter({( name : contactList) -> Bool in
//                return name.name.lowercased().contains(searchText.lowercased())
//            },
//
//
//        }
//
//
//
//        tableView.reloadData()
//        }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? ViewController)?.contactsList = contactsList // Here you pass the to your original view controller
    }
    
}




