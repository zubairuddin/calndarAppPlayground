//
//  ContactsViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 28/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import ContactsUI


class ContactsViewController: UITableViewController {
    
    
    @IBOutlet var searchContacts: UISearchBar!
    
    
    var contactsList = [contactList]()
//    property for holding the filtered data
    var filteredData = [contactList]()
    
//    this tells the controller we want to  use the same view to display the results as we use to search
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
//        allows our view controller to be informed when we upate the search text
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Contacts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
       
        
        fetchContacts()

        // Do any additional setup after loading the view.
    }
    
//    this function is used to fethc the contacts
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
                        print(contact.givenName)
                    
                        self.contactsList.append(contactList(name: contact.givenName + " " + contact.familyName, phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "", selectedContact: false))
                        
                        print(self.contactsList)
                        
                        self.tableView.reloadData()
                        
                    })
                    
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
        
        if isFiltering() {
        return filteredData.count
        }else {
            return contactsList.count
        }
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)

        let item: contactList
    
        if isFiltering(){
            item = filteredData[indexPath.row]
            print(item)
            print(filteredData)
        }
        else{
             item = contactsList[indexPath.row]
            print(item)
            print(filteredData)
        }
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.phoneNumber
        
        if item.selectedContact == true {
            cell.accessoryType = .checkmark
            
        } else{
            cell.accessoryType = .none
        }
        
        print(isFiltering())
        return cell
        

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let row = contactsList[indexPath.row]
        
        //        check to see if there already exist a check mark, if there is remove it, if there isnt add it
        
        //        sets the done property on the item in the array to the opposite of what it is now
        
        contactsList[indexPath.row].selectedContact = !contactsList[indexPath.row].selectedContact
        
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        if searchBar.text == nil || searchBar.text == "" {
//            isSearching = false
//            view.endEditing(true)
//            tableView.reloadData()}
//            else{
//                isSearching = true
//
//             filterContentForSearchText(searchController.searchBar.text!)
//            }
//
//        }
    
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All"){
        filteredData = contactsList.filter({(list : contactList) -> Bool in return list.name.lowercased().contains(searchText.lowercased())})
        print(filteredData)
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
        
    }
    
    }

//tells the view controller that the seacrch is being updated
extension ContactsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}



