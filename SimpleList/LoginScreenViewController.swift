//
//  LoginScreenViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 2/27/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit
import CoreData

//Keychain Configuration
struct KeychainConfiguration {
    static let serviceName = "DocVault"
    static let accessGroup: String? = nil
}

class LoginScreenViewController: UIViewController, UITextFieldDelegate {

    var password: String = ""
    var passwordHint: String = ""
    var passwordFound: Bool = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordHintText: UITextField!
    @IBOutlet weak var viewHintButton: UIButton!
    @IBOutlet weak var labelInstructions: UILabel!
    @IBOutlet weak var loginButtonTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordText.delegate = self
        confirmPasswordText.delegate = self
        passwordHintText.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        setupLoginScreen()
        passwordText.text = ""
        confirmPasswordText.text = ""
        passwordHintText.text = ""
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
    }

    //MARK: Private Functions
    
    
    private func msgBox(title: String, text: String) {
        
        var msgTitle: String = "Message"
        
        if !title.isEmpty {
            msgTitle = title
        }
    
        let alert = UIAlertController(title: msgTitle, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func setupLoginScreen () {
  
//
// Old
//
//        if getPassword() {
//            confirmPasswordText.isHidden = true
//            passwordHintText.isHidden = true
//            viewHintButton.isHidden = false
//            loginButton.setTitle("Login", for: .normal)
//        } else {
//            confirmPasswordText.isHidden = false
//            passwordHintText.isHidden = false
//            viewHintButton.isHidden = true
//            loginButton.setTitle("Confirm", for: .normal)
//        }
        
// New
        password = readPasswordFromKeychain()
        passwordHint = getPasswordHint()
        
        if password.isEmpty {
            
            confirmPasswordText.isHidden = false
            passwordHintText.isHidden = false
            viewHintButton.isHidden = true
            loginButton.setTitle("Confirm", for: .normal)
            labelInstructions.isHidden = false
            loginButtonTopConstraint.constant = 24
            
        } else {

            confirmPasswordText.isHidden = true
            passwordHintText.isHidden = true
            viewHintButton.isHidden = false
            loginButton.setTitle("Login", for: .normal)
            labelInstructions.isHidden = true
            loginButtonTopConstraint.constant = -72
        }
        
        
    }

    private func savePasswordHint() -> Bool {

        print("savePasswordHint(): BEGIN")
    
        var ret: Bool = false
    
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
    
        // save to Items table
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "PasswordHint", in: managedContext)!
    
        let thisItem = NSManagedObject(entity: entity, insertInto: managedContext)
    
        // 3
        thisItem.setValue(passwordHint, forKeyPath: "password_hint")
    
        // 4
        do {
        try managedContext.save()
        ret = true
        } catch let error as NSError {
        print("savePasswordHint(): Could not save. \(error), \(error.userInfo)")
        ret = false
        }
    
        print("savePasswordHint(): END")
    
        return ret

    }
    
    private func savePasswordAndPasswordHint() -> Bool {
        
        print("savePasswordAndPasswordHint(): BEGIN")

        var ret: Bool = false
        
        if writePasswordToKeychain(password: password) {
            
            if savePasswordHint() {
                ret = true
            } else {
                ret = false
                print("savePasswordAndPasswordHint(): could not save password hint")
            }
            
        } else {
            ret = false
            print("savePasswordAndPasswordHint(): could not save password")
        }
        
        print("savePasswordAndPasswordHint(): END")

        return ret
        
    }
    
    private func savePassword() -> Bool {
        
        print("savePassword(): BEGIN")
        
        var ret: Bool = false
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // save to Items table
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Password", in: managedContext)!
        
        let thisItem = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        thisItem.setValue(password, forKeyPath: "password")
        thisItem.setValue(passwordHint, forKeyPath: "password_hint")
        
        // 4
        do {
            try managedContext.save()
            ret = true
        } catch let error as NSError {
            print("savePassword(): Could not save. \(error), \(error.userInfo)")
            ret = false
        }
        
        print("savePassword(): END")

        return ret
    }
    
    private func getPasswordHint() -> String {

        print("getPasswordHint(): BEGIN")
        
        var pwh: String = ""
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "PasswordHint")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            print("getPasswordHint(): results: \(results.count)")
            
            if results.count != 0 {
                
                let match = results[0] as! NSManagedObject
                pwh = match.value(forKey: "password_hint") as! String
                print("getPasswordHint(): passwordHint \(pwh)")
                
            } else {
                print("getPasswordHint(): no password record found")
            }
            
        } catch let error as NSError {
            print("getPasswordHint(): Could not fetch. \(error), \(error.userInfo)")
        }
        
        print("getPasswordHint(): END")
        
        return pwh

    }
    
    
    private func getPassword() -> Bool {
        
        print("getPassword(): BEGIN")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Password")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            print("getPassword(): results: \(results.count)")
            
            if results.count != 0 {
                
                let match = results[0] as! NSManagedObject
                password = match.value(forKey: "password") as! String
                passwordHint = match.value(forKey: "password_hint") as! String
                print("getPassword(): password: \(password), passwordHint \(passwordHint)")
                print("getPassword(): END")
                
                if password.isEmpty {
                    return false
                } else {
                    return true
                }
                
            } else {
                print("getPassword(): no password record found")
            }
            
        } catch let error as NSError {
            print("getPassword(): Could not fetch. \(error), \(error.userInfo)")
        }

        print("getPassword(): END")
        
        return false
        
    }
    
    private func readPasswordFromKeychain() -> String {
        
        let accountName: String = ""
        var password: String = ""
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: accountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            password = keychainPassword
            
        } catch {
            //fatalError("Error reading password from keychain - \(error)")
            print("readPasswordFromKeychain: password not found in keychain")
        }
        
        return password
        
    }
    
    private func writePasswordToKeychain(password: String) -> Bool {
        
        let accountName: String = ""
        
        if password == "" {
            print("writePasswordToKeyChain: password cannot be empty")
            return false
        }
        
        // 5
        do {
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: accountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(password)
            print("writePasswordToKeyChain: pasword saved to keychain")
            return true
        } catch {
            //fatalError("Error updating keychain - \(error)")
            print("writePasswordToKeyChain: Error updating keychain - \(error)")
            return false
        }
        
    }
    
    private func deletePasswordFromKeychain() -> Bool {
        
        let accountName: String = ""
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: accountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            try passwordItem.deleteItem()
            
            print("deletePasswordFromKeychain: password deleted from keychain")
            
            return true
            
        } catch {
            //fatalError("Error updating keychain - \(error)")
            print("deletePasswordFromKeychain: Error deleting frin keychain - \(error)")
            return false
        }
        
    }

    private func launch1stScreen() {
        
        //switching the screen
        let profileViewController = self.storyboard?.instantiateViewController(withIdentifier:  "ItemTableViewController") as! ItemTableViewController
        
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
        //self.textPassword.text = ""
        //self.textConfirmPassword.text = ""
        
        //self.navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func viewHintButton(_ sender: UIButton) {
        
        msgBox(title: "Password Hint", text: passwordHint)
        
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        
        if deletePasswordFromKeychain() {
            print("password deleted from keychain")
        } else {
            print("password not deleted from keychain")
        }
        
        // delete from core data - old
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Password")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            
            password = ""
            passwordHint = ""
            passwordFound = false
            
        } catch {
            print("Error while deleting from Password")
        }

        setupLoginScreen()

    }
    
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        let pw = passwordText.text ?? ""
        let confirmPW = confirmPasswordText.text ?? ""
        let pwHint = passwordHintText.text ?? ""
        
        if password.isEmpty {
            
            // pw and confirmPW cannot be empty
            if pw.isEmpty {
                msgBox(title: "", text: "Must enter a password to continue")
            } else if confirmPW.isEmpty {
                msgBox(title: "", text: "Must confirm password to continue")
            } else if pwHint.isEmpty {
                msgBox(title: "", text: "Must enter a password hint to continue")
            } else {
                // need to confirm and save password to db
                if pw == confirmPW {
                    password = pw
                    passwordHint = pwHint
                    
                    // save to db
                    //if savePassword() {
                        if savePasswordAndPasswordHint() {
                        // password saved
                        launch1stScreen()
                    } else {
                        // something went wrong saving password
                        fatalError("Error saving password")
                    }
                } else {
                    // passwords don't match
                    msgBox(title: "", text: "Passwords do not match!")
                }

            }
            
        } else {
            // need to compare password entered to saved password
            if pw == password {
                launch1stScreen()
            } else {
                msgBox(title: "", text: "Incorrect password!")
            }
        }
        
        self.view.endEditing(true)
        
    }

}
