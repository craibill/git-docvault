//
//  OldPasswordViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 5/14/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit

struct passwordStep {
    static let enterNewPassword = 1
    static let verifyNewPassword = 2
    static let enterPasswordHint = 3
}

struct passwordMode {
    static let onOrOffMode = 1
    static let changeMode = 2
}

class OldPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBOutlet weak var buttonNext: UIButton!
    
    var mode: Int?

    var newPassword: String?
    var newPasswordHint: String?
    
    var currentStep = passwordStep.enterNewPassword

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textPassword.delegate = self
        
        buttonSave.isEnabled = false
       
        if mode == passwordMode.changeMode {
            
            textPassword.becomeFirstResponder()
            labelMessage.text = "Enter New Password"
            navigationItem.title = "Change Password"
            newPassword = ""
            newPasswordHint = ""
    
        } else {
            
            textPassword.becomeFirstResponder()
            labelMessage.text = "Enter New Password"
            navigationItem.title = "New Password"
            newPassword = ""
            newPasswordHint = ""
        }

        
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
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
         //dismiss(animated: true, completion: nil)
        //self.view.window!.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)
        ////navigationController?.popViewController(animated: true)
        //navigationController?.popToRootViewController(animated: true)

//        if let owningNavigationController = navigationController {
//            // user tapped an existing document (editing a document) to get here
//            owningNavigationController.popViewController(animated: true)
//        }
    }
    

    
    @IBAction func next(_ sender: UIButton) {
          
        if currentStep == passwordStep.enterNewPassword {
            
            newPassword = textPassword.text!
            labelMessage.text = "Verify New password"
            textPassword.text = ""
            currentStep = passwordStep.verifyNewPassword
            
        } else if currentStep == passwordStep.verifyNewPassword {
            
            if newPassword == textPassword.text {
                //save the password
                // return to settings screen
                
                labelMessage.text = "Enter Password Hint"
                textPassword.text = ""
                textPassword.keyboardType = UIKeyboardType.default
                textPassword.isSecureTextEntry = false
                buttonNext.isHidden = true
                currentStep = passwordStep.enterPasswordHint
                
            } else {
                
                let alert = UIAlertController(title: "New Password", message: "New Passwords do not match!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        } else if currentStep == passwordStep.enterPasswordHint {
            
                // place holder
            
        }

    }
    
    //MARK: Actions
    
    @IBAction func textFieldChanged(_ sender: UITextField) {

        if currentStep == passwordStep.enterPasswordHint {
            if sender.text != "" {
                buttonSave.isEnabled = true
                newPasswordHint = textPassword.text
            } else {
                buttonSave.isEnabled = false
            }
        }

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Private Functions
    @objc private func handleAppDidBecomeActive() {
        
        if globalUsePassword == true {
            self.performSegue(withIdentifier: "ReturnToLoginFromOldPassword", sender: self)
        }
    }

}
