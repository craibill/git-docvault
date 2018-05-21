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
//struct KeychainConfiguration {
//    static let serviceName = "DocVault"
//    static let accessGroup: String? = nil
//}
//
class LoginScreenViewController: UIViewController, UITextFieldDelegate {

    var password: String = ""
    var passwordHint: String = ""
    var passwordFound: Bool = false
    var usePassword: Bool = false
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var viewHintButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordText.delegate = self
        
        passwordText.isHidden = true
        loginButton.isHidden = true
        viewHintButton.isHidden = true
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.blue.cgColor
        
        // Do any additional setup after loading the view.
        
        let upwd = getUsePassword()
        setUsePassword(usePW: upwd)

        if usePassword == true {

            passwordText.isHidden = false
            loginButton.isHidden = false
            viewHintButton.isHidden = false

            passwordText.isSelected = true
            passwordText.becomeFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if usePassword == false {
            // beginning with version 0.1, build 3, if user has not
            // turned on use password, then skip the login screen altogether

            // skip logging in just go to 1st screen
            launch1stScreen()
            
        } else {
            
            // make the controls visible
            passwordText.isHidden = false
            loginButton.isHidden  = false
            viewHintButton.isHidden = false

            setupLoginScreen()
            passwordText.text = ""

            passwordText.becomeFirstResponder()

        }

        
        
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
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
     
        if let sourceViewController = segue.source as? ItemTableViewController {
            
            print("returned to login from ItemTableViewController")

            usePassword = globalUsePassword
            //setUsePassword(usePW: usePw)
            
        } else if let sourceViewController = segue.source as? SettingsScreenViewController {

            print("returned to login from SettingsScreenViewController")

            usePassword = globalUsePassword
            //setUsePassword(usePW: usePw)

        } else if let sourceViewController = segue.source as? ItemViewController {
            print("returned to login from ItemViewController")

            usePassword = globalUsePassword
            //setUsePassword(usePW: usePw)

        } else if let sourceViewController = segue.source as? ZoomImageViewController {
            print("returned to login from ZoomImageViewController")

            usePassword = globalUsePassword
            //setUsePassword(usePW: usePw)

        } else if let sourceViewController = segue.source as? OldPasswordViewController {
            print("returned to login from OldPasswordViewController")

            usePassword = globalUsePassword
            //setUsePassword(usePW: usePw)

        }

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
  
        password = readPasswordFromKeychain()
        passwordHint = getPasswordHint()
        
        if password.isEmpty {
            
            viewHintButton.isHidden = true
            loginButton.setTitle("Confirm", for: .normal)
            
        } else {

            viewHintButton.isHidden = false
            loginButton.setTitle("Login", for: .normal)
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
    
    
    private func getUsePassword() -> Bool {

        print("getUsePassword(): BEGIN")
        
        // default to not using password
        // user must opt in
        var upw: Bool = false
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            print("getUsePassword(): results: \(results.count)")
            
            if results.count != 0 {
                
                let match = results[0] as! NSManagedObject
                upw = match.value(forKey: "use_password") as! Bool
                print("getUsePassword(): use_password \(upw)")
                
            } else {
                print("getUsePassword(): no use_password record found")
                
                // if not password record found, write in to core data
                let r = saveUsePassword(usePW: upw)
                
                if r == true {
                    print("succesfully wrote usePassword to core data")
                } else {
                    print("could not write usePassword to core data")
                }
            }
            
        } catch let error as NSError {
            print("getUsePassword(): Could not fetch. \(error), \(error.userInfo)")
        }
        
        print("getUsePassword(): END")
        
        return upw

    }
    
    private func saveUsePassword(usePW: Bool) -> Bool {
        
        print("saveUsePassword(): BEGIN")
        
        var ret: Bool = false
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // save to Items table
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Settings", in: managedContext)!
        
        let thisItem = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        thisItem.setValue(usePW, forKeyPath: "use_password")
        
        // 4
        do {
            try managedContext.save()
            ret = true
        } catch let error as NSError {
            print("saveUsePassword(): Could not save. \(error), \(error.userInfo)")
            ret = false
        }
        
        print("saveUsePassword(): END")
        
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
    
    /*
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
 
 */
    

    private func launch1stScreen() {
        
        //switching the screen
        let itemTblViewCtrlr = self.storyboard?.instantiateViewController(withIdentifier:  "ItemTableViewController") as! ItemTableViewController
        
        itemTblViewCtrlr.usePassword = usePassword
        
        if usePassword {
            self.navigationController?.pushViewController(itemTblViewCtrlr, animated: true)
        } else {
            self.navigationController?.pushViewController(itemTblViewCtrlr, animated: false)
        }
        
        //self.textPassword.text = ""
        //self.textConfirmPassword.text = ""
        
        //self.navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    
    private func setUsePassword(usePW: Bool) {
        
        usePassword = usePW
        globalUsePassword = usePW
        
    }
    
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
        
        
        // need to compare password entered to saved password
        if pw == password {
            launch1stScreen()
        } else {
            msgBox(title: "", text: "Incorrect password!")
        }
        
        self.view.endEditing(true)
        
    }

}
