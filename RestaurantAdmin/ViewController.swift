//
//  ViewController.swift
//  RestaurantAdmin
//
//  Created by Muhammed Sahil on 01/06/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Cocoa

private struct CellIdentifiers {
    static let nameCell = "tableCellID"
}

class ViewController: NSViewController {
    
    var menuItems: [MenuItem] = []
    
    var newlyAddedMenuItem: MenuItem? = nil {
        didSet {
            // For pass of value of new item
            if let newItem = self.newlyAddedMenuItem {
                menuItems.append(newItem)
                DispatchQueue.main.async {
                    self.resetDetailView()
                    self.tableView.reloadData()
                }
                
                self.newlyAddedMenuItem = nil
            }
        }
    }
    
    var isInEditMode: Bool = false {
        didSet {
            if isInEditMode {
                enableControls()
                editButton.title = "Save"
                deleteButton.isHidden = true
                //tableView.isEnabled = false
                addButton.isEnabled = false
                reloadButton.isEnabled = false
            } else {
                disableControls()
                editButton.title = "Edit"
                deleteButton.isHidden = false
                //tableView.isEnabled = true
                addButton.isEnabled = true
                reloadButton.isEnabled = true
            }
        }
    }
    
    
    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var idLabel: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet var descriptionTextView: NSTextView!
    @IBOutlet weak var priceTextField: NSTextField!
    @IBOutlet weak var prepTimeTextField: NSTextField!
    @IBOutlet weak var imageUrlTextField: NSTextField!
    @IBOutlet weak var editButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var reloadButton: NSButton!
    
    override func viewWillAppear() {
        ContactServerAndUpdateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        isInEditMode = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
            
        }
    }
    
    @IBAction func editButtonTapped(_ sender: NSButton) {
        if isInEditMode {
            guard let menuItem = editMenuItem() else {return}
            MenuController.shared.submitMenuItem(menuItem) { (editedMenuItem) in
                
                if let editedMenuItem = editedMenuItem {
                    DispatchQueue.main.async {
                        self.menuItems[self.tableView.selectedRow] = editedMenuItem
                        self.resetDetailView()
                        self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [0])
                        self.uploadDetailView()
                    }
                }
                
            }
        }
        
        isInEditMode = !isInEditMode
        imageUrlTextField.resignFirstResponder()
    }
    
    @IBAction func deleteButtonTapped(_ sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Delete"
        alert.icon = NSImage(named: "logo")
        alert.informativeText = "Are you sure you want to delete this Menu Item? It cannot be recovered after deleting."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        for button in alert.buttons {
            button.isBordered = false
            button.contentTintColor = hexStringToNSColor(hex: "#FF8768")
        }
        
        let modalResult = alert.runModal()
        
        switch modalResult {
            
        case .alertFirstButtonReturn:
            guard let itemID = menuItems[tableView.selectedRow].id else {return}
            MenuController.shared.deleteMenuItem(id: itemID) { (code) in
                if let code = code, code == "DELETED" {
                    DispatchQueue.main.async {
                        let deletingRow = self.tableView.selectedRow
                        self.menuItems.remove(at: deletingRow)
                        self.resetDetailView()
                        self.tableView.removeRows(at: [deletingRow], withAnimation: .slideLeft)
                        self.tableView.selectRowIndexes([(deletingRow)], byExtendingSelection: false) // same index used as assumed deletion from front of array
                    }
                } else {
                    print("Error in deletion")
                }
            }
            
        case .alertSecondButtonReturn:
            dismiss(nil)
            
        default:
            print("error in  delete button alert")
        }
        
    }
    
    @IBAction func reloadButtonTapped(_ sender: NSButton) {
        //presentAlert(withMessage: "HelloWorld", andInfo: "World Wide Web")
        ContactServerAndUpdateUI()
    }
    
    @IBAction func AddButtonTapped(_ sender: NSButton) {
        // Already set in storyboard
    }
    
    
    func disableControls() {
        idLabel.isEnabled = false
        categoryPopup.isEnabled = false
        descriptionTextView.isEditable = false
        priceTextField.isEnabled = false
        prepTimeTextField.isEnabled = false
        imageUrlTextField.isEnabled = false
        
        nameTextField.isEditable = false
        imageUrlTextField.isEditable = false
    }
    
    func enableControls() {
        idLabel.isEnabled = true
        categoryPopup.isEnabled = true
        descriptionTextView.isEditable = true
        priceTextField.isEnabled = true
        prepTimeTextField.isEnabled = true
        imageUrlTextField.isEnabled = true
        
        nameTextField.isEditable = true
        imageUrlTextField.isEditable = true
    }
    
    func resetDetailView() {
        editButton.isEnabled = false
        deleteButton.isEnabled = false
        
        idLabel.integerValue = Int()
        imageView.image = NSImage()
        nameTextField.stringValue = "Name"
        categoryPopup.selectItem(withTitle: "X") //just to not show any selection in popup button
        descriptionTextView.string = "Description"
        priceTextField.doubleValue = Double()
        prepTimeTextField.integerValue = Int()
        imageUrlTextField.stringValue = String()
        
    }
    
    func ContactServerAndUpdateUI() {
        MenuController.shared.fetchCategories { (categories) in
            if let categories = categories {
                DispatchQueue.main.async {
                    self.categoryPopup.removeAllItems()
                    self.categoryPopup.addItems(withTitles: categories)
                }
                
            }
        }
        
        MenuController.shared.fetchAllItems { (allMenuItems) in
            if let allMenuItems = allMenuItems {
                self.menuItems = allMenuItems
                DispatchQueue.main.async {
                    self.resetDetailView()
                    self.tableView.reloadData()
                }
            } else {
                print("Error")
            }
        }
    }
    
    func editMenuItem() -> MenuItem? {
        guard !nameTextField.stringValue.isEmpty, !descriptionTextView.string.isEmpty, !imageUrlTextField.stringValue.isEmpty, !prepTimeTextField.stringValue.isEmpty, !priceTextField.stringValue.isEmpty else {
            print("Please fill in the required text fields!")
            presentAlert(withMessage: "Error", andInfo: "Please fill in the required text fields.")
            return nil
        }
        
        guard let category = categoryPopup.titleOfSelectedItem else {
            print("Please choose a category")
            presentAlert(withMessage: "Error", andInfo: "Please choose a category")
            return nil
        }
        
        guard let imageURL = URL(string: imageUrlTextField.stringValue), imageUrlTextField.stringValue.isValidURL, imageUrlTextField.stringValue.hasSuffix(".jpg") || imageUrlTextField.stringValue.hasSuffix(".jpeg") else {
            print("Please use a valid address for the image's url")
            presentAlert(withMessage: "Error", andInfo: "Please use a valid address for the image's url")
            return nil
        }
        
        let prepText = prepTimeTextField.stringValue
        guard let prepTime = Int(prepText) else {
            print("Please use an integer for preparation time")
            presentAlert(withMessage: "Error", andInfo: "Please use an integer for preparation time")
            return nil
        }
        
        let priceText = priceTextField.stringValue
        guard let price = Double(priceText) else {
            print("Please use a double for price")
            presentAlert(withMessage: "Error", andInfo: "Please use a double for price")
            return nil
        }
        
        let description = descriptionTextView.string
        
        let name = nameTextField.stringValue
        
        let id = idLabel.integerValue
        
        let newMenuItem = MenuItem(id: id, name: name, description: description, price: price, category: category, imageURL: imageURL, preparationTime: prepTime)
        
        return newMenuItem
    }
    
    func presentAlert(withMessage message: String, andInfo info: String) {
        let alert = NSAlert()
        alert.icon = NSImage(named: "logo")
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Ok")
        
        for button in alert.buttons {
            button.isBordered = false
            button.contentTintColor = hexStringToNSColor(hex: "#FF8768")
        }
        
        alert.messageText = message
        alert.informativeText = info
        alert.runModal()
    }
    

}


extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return menuItems.count
    }
}


extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CellIdentifiers.nameCell), owner: nil) as? NSTableCellView {
            let currentMenuItem = menuItems[row]
            cell.textField?.stringValue = currentMenuItem.name
            return cell
        } else {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        uploadDetailView()
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        // Disable the ability to change selection in tableview if the user is currently editing an item
        if isInEditMode {
            return false
        } else {
            return true
        }
    }
    
    
    func uploadDetailView() {
        editButton.isEnabled = true
        deleteButton.isEnabled = true
        
        imageView.image = NSImage()
        
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 else {
            tableView.deselectAll(self)
            resetDetailView()
            return
        }

        let menuItem = menuItems[selectedRow]
        
        MenuController.shared.fetchImage(url: menuItem.imageURL) { (image) in
            guard let image = image else {
                DispatchQueue.main.async {
                    self.imageView.image = NSImage()
                }
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        idLabel.integerValue = menuItem.id ?? 0
        nameTextField.stringValue = menuItem.name
        categoryPopup.selectItem(withTitle: menuItem.category)
        descriptionTextView.string = menuItem.description
        priceTextField.doubleValue = menuItem.price
        prepTimeTextField.integerValue = menuItem.preparationTime
        imageUrlTextField.stringValue = menuItem.imageURL.absoluteString
    }
    
}
