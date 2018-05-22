//
//  ItemViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 2/22/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit
import os.log
import MessageUI
import Photos


struct viewMode {
    static let addMode = 1
    static let editMode = 2
}

class ItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    


    //MARK: Properties
    
    @IBOutlet weak var textDescription: UITextField!
    @IBOutlet weak var imageFullSizeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    
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
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        

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
    
    // MARK: Protocols
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        self.dismiss(animated: true, completion: nil)

    }

//    func mailComposeController(controller: MFMailComposeViewController,
//                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
//
//        //controller.dismiss(animated: true, completion: nil)
//        self.dismiss(animated: true, completion: nil)
//    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Targets
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Image saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }
    
    //MARK: Actions
    
    @IBAction func buttonSend(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Share Image", message: "What would you like to do?", preferredStyle: .actionSheet)
        

        let messageButton = UIAlertAction(title: "Message", style: .default, handler: { (action) -> Void in
            
            print("Send Message button tapped")
            self.sendMessage()
            
        })
        
        let  emailButton = UIAlertAction(title: "Email", style: .default, handler: { (action) -> Void in
            
            print("Email button tapped")
            self.sendEmail()
            
        })

        let  saveButton = UIAlertAction(title: "Save to camera roll", style: .default, handler: { (action) -> Void in
            
            print("Save to camera toll button tapped")
            self.saveToCameraRoll()
            
        })

        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("Cancel button tapped")
        })
        
        
        alertController.addAction(messageButton)
        alertController.addAction(emailButton)
        alertController.addAction(saveButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
        
    }
    
    
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

    private func sendMessage() {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Image sent via DocVault"
            //controller.recipients = [phoneNumber.text]
            controller.messageComposeDelegate = self
            
            //Add Image as Attachment
            
            
            if MFMessageComposeViewController.canSendAttachments() {
                let imageData = UIImageJPEGRepresentation(imageFullSizeImage.image!, 1.0)
                controller.addAttachmentData(imageData!, typeIdentifier: "image/jpg", filename: "image.jpg")
            }
            
            self.present(controller, animated: true, completion: nil)
        }

    }
    
    private func sendEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            
            //mail.setCcRecipients(["yyyy@xxx.com"])
            mail.setSubject("Image sent via DocVault")
            mail.setMessageBody("Here is your image", isHTML: false)
            
            //let imageData: NSData = UIImagePNGRepresentation(imageFullSizeImage.image!)! as NSData
            let imageData = UIImageJPEGRepresentation(imageFullSizeImage.image!, 1.0)
            
            //mail.addAttachmentData(imageData as Data, mimeType: "image/png", fileName: "imageName.png")
            mail.addAttachmentData(imageData!, mimeType: "image/png", fileName: "image.jpg")
            
            self.present(mail, animated: true, completion: nil)
        }

    }
    
    private func saveToCameraRoll() {
        
        let pickedImage = item?.image
        
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            
            // UIImageWriteToSavedPhotosAlbum(pickedImage!, nil, nil, nil)
            UIImageWriteToSavedPhotosAlbum(pickedImage!, self,
                                           #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            
        } else if (status == PHAuthorizationStatus.denied) {
            
            // Access has been denied.
            msgBox(title: "Access Needed" , text: "Please allow DocVault access to Photos")
            
        } else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                    UIImageWriteToSavedPhotosAlbum(pickedImage!, nil, nil, nil)
                    
                }
                    
                else {
                    
                    self.msgBox(title: "Access Needed" , text: "Please allow DocVault access to Photos")
                    
                }
            })
            
            
        } else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
        
    }
    
    private func msgBox(title: String, text: String) {
        
        var msgTitle: String = "Message"
        
        if !title.isEmpty {
            msgTitle = title
        }
        
        let alert = UIAlertController(title: msgTitle, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    @objc private func handleAppDidBecomeActive() {
        
        if globalUsePassword == true {
            self.performSegue(withIdentifier: "ReturnToLoginFromItem", sender: self)
        }
    }

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
