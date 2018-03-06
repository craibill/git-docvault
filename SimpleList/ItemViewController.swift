//
//  ItemViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 2/22/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit
import os.log

struct viewMode {
    static let addMode = 1
    static let editMode = 2
}

class ItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    //MARK: Properties
    
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var textDescription: UITextField!
    @IBOutlet weak var imageFullSizeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    var item: ItemClass?
    var mode: Int? = viewMode.addMode
    var descriptionDidChange: Bool?
    var imageDidChange: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up views if editing an existing item
        if let item = item {
            navigationItem.title = item.description
            textDescription.text = item.description
            imageFullSizeImage.image = item.image
            descriptionDidChange = false
            imageDidChange = false
            mode = viewMode.editMode

        } else {
            mode = viewMode.addMode
            
        }
        
        saveButton.isEnabled = false
        
        
        // Do any additional setup after loading the view.
        textDescription.delegate = self
        
        navigationController?.setToolbarHidden(false, animated: true)
    }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // depending on style of presentation (modal or push presentation), this view
        // controller needs to be dismssedin two different ways
        
        let isPresentingInAddItemMode = presentingViewController is UINavigationController
        
        if isPresentingInAddItemMode {
            // user tapped the Add button to get here
            dismiss(animated: true, completion: nil)
            
        }
            
        else if let owningNavigationController = navigationController {
            // user tapped an existing document (editing a document) to get here
            owningNavigationController.popViewController(animated: true)
        }
        else {
            // this should never happen
            fatalError("The DocumentViewController is not inside a navigation controller")
            
        }
        
        
        
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        view.endEditing(true)

        super.prepare(for: segue, sender: sender)
        
        print("segue.identifer: \(segue.identifier)")
        print("sender: ***[\(sender.debugDescription)]***")
        
        if segue.identifier == "Zoom" {
            
            guard let zoomImageViewController = segue.destination as? ZoomImageViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            zoomImageViewController.image = imageFullSizeImage.image

        } else {
            // Configure the destination view controller only when the save button is pressed.
            guard let button = sender as? UIBarButtonItem, button === saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
            
            let description = textDescription.text ?? ""
            let photo = imageFullSizeImage.image
        
            if mode == viewMode.addMode {
                
                descriptionDidChange = true
                imageDidChange = true
                
                // create a new item instance of ItemClass and intitialize it
                item = ItemClass(description: description, image: photo)
            } else {
                // return the exiting item
                
                if descriptionDidChange == true {
                    item?.description = description
                }
                
                if imageDidChange == true {
                    item?.image = photo
                    item?.createThumbsizeImage()
                }
                
            }
        }
    }
    

    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        updateSaveButtonState()
        
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        
        updateSaveButtonState()

    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // the info dictionary may contaon multiple representations of the image we want to select the original
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else
        {
            fatalError("Expected a dictionary containing an image, but was provided: \(info)")
        }
        
        // set photoImageView to displauy the selected image
        imageFullSizeImage.image = selectedImage
        
        imageDidChange = true
        if !(textDescription.text?.isEmpty)! {
            saveButton.isEnabled = true
        }
        
        // dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    @IBAction func showCamera(_ sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){

            // UIImagePickerControler is a view controller that lets a user pick media from their photo library
            // hide the keyboard
            let imagePickerController = UIImagePickerController()
            
            // only allows photos to be picked, not taken
            imagePickerController.sourceType = .camera
            
            // make sure ViewController is notified when the user picks an image
            imagePickerController.delegate = self
            
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectImage(_ sender: UIBarButtonItem) {
        
        // UIImagePickerControler is a view controller that lets a user pick media from their photo library
        // hide the keyboard
        let imagePickerController = UIImagePickerController()
        
        // only allows photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        
        // make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    //MARK: Private Functions
    
    private func updateSaveButtonState() {
        
        if textDescription.text != item?.description {
            descriptionDidChange = true
            if (textDescription.text?.isEmpty)! {
                saveButton.isEnabled = false
            } else {
                saveButton.isEnabled = true
                navigationItem.title = textDescription.text
            }
        }

    }
}
