//
//  AddMenuItemVC.swift
//  RestaurantAdmin
//
//  Created by Muhammed Sahil on 12/06/19.
//  Copyright © 2019 MDAK. All rights reserved.
//

import Cocoa

class AddMenuItemVC: NSViewController {

    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet var descriptionTextView: NSTextView!
    @IBOutlet weak var imageUrlTextField: NSTextField!
    @IBOutlet weak var prepTimeTextField: NSTextField!
    @IBOutlet weak var priceTextField: NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    
    override func viewWillAppear() {
        MenuController.shared.fetchCategories { (categories) in
            if let categories = categories {
                DispatchQueue.main.async {
                    self.categoryPopup.removeAllItems()
                    self.categoryPopup.addItems(withTitles: categories)
                    self.categoryPopup.selectItem(withTitle: "X") //just to not show any selection in popup button
                }
                
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    @IBAction func saveButtonTapped(_ sender: NSButton) {
        guard let menuItem = createMenuItem() else {return}
        
        MenuController.shared.submitMenuItem(menuItem) { (addedMenuItem) in
            if let addedMenuItem = addedMenuItem {
                guard let sourceVC = self.presentingViewController as? ViewController else {return}
                sourceVC.newlyAddedMenuItem = addedMenuItem
                
                DispatchQueue.main.async {
                    self.dismiss(nil)
                }
            } else {
                print("Error: addedMenuItem is nil")
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: NSButton) {
        self.dismiss(nil)
    }
    
    func createMenuItem() -> MenuItem? {
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
        
        let newMenuItem = MenuItem(id: nil, name: name, description: description, price: price, category: category, imageURL: imageURL, preparationTime: prepTime)
        print(newMenuItem)
        
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

