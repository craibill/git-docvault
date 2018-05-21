//
//  SettingsScreenViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 5/14/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit
import CoreData

class SettingsScreenViewController: UIViewController, UITextFieldDelegate  {

    @IBOutlet weak var optionUsePassword: UISwitch!
    @IBOutlet weak var textAppVersion: UITextField!
    @IBOutlet weak var textAppBuild: UITextField!
    @IBOutlet weak var buttonChangePassword: UIButton!
    
    var password: String = ""
    var usePassword: Bool? 
    var appVersion: String = ""
    var appBuild: String = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let (appVersion, appBuild) = getVersionAndBuild()
        textAppVersion.text = appVersion
        textAppBuild.text = appBuild
        
        let upwd = getUsePassword()
        setUsePassword(usePW: upwd)
        
        password = readPasswordFromKeychain()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        optionUsePassword.isOn = usePassword!
        buttonChangePassword.isEnabled = usePassword!

    }
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
         dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Actions
    
    @IBAction func buttonBack(_ sender: UIBarButtonItem) {
    
        //self.performSegue(withIdentifier: "unwindToItemListFromSettings", sender: self)
        self.performSegue(withIdentifier: "BackToItemsListFromSettings", sender: self)
        
        
    }
    
    @IBAction func buttonChangePassword(_ sender: UIButton) {
        
        // first ahow an alert to ask for the current password
        // and if correct seque to the change password screen
        // if not stay here
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enter your password", message: "", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            let p = textField?.text ?? ""
            self.handleChangePassword(pw: p)
            
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        var ret = true
        
        if identifier == "OnOrOff" {
            if optionUsePassword.isOn {
                
                // user just turned use password on
                // return true so we can segue to the add/change password screen
                ret = true
                
            } else {
                
                // user just turned user password off
                // show an alert to ask for the old password to confirm turning off the password lock
                
                //1. Create the alert controller.
                let alert = UIAlertController(title: "Enter your password", message: "", preferredStyle: .alert)
                
                //2. Add the text field. You can configure it however you need.
                alert.addTextField { (textField) in
                    textField.text = ""
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Password"
                }
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    print("Text field: \(textField?.text)")
                    let p = textField?.text ?? ""
                    ret = self.handleTurnOffPassword(pw: p)
                    
                }))
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        return ret
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        switch(segue.identifier ?? "") {
        case "ChangePassword":

            guard let changePasswordViewController = segue.destination as? OldPasswordViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            changePasswordViewController.mode = passwordMode.changeMode

        case "OnOrOff":
            
            guard let changePasswordViewController = segue.destination as? OldPasswordViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            changePasswordViewController.mode = passwordMode.onOrOffMode

        case "BackToItemsListFromSettings":
            print("segue identifier: '\(segue.identifier ?? "")'")
        
        case "ReturnToLoginFromSettings":
            print("segue identifier: '\(segue.identifier ?? "")'")
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
            
        }


    }

    @IBAction func unwindToSettingsCancel(sender: UIStoryboardSegue) {
    
        print("detecting cancel!")
        optionUsePassword.isOn = usePassword!
    }
    
    
    @IBAction func unwindToSettings(sender: UIStoryboardSegue) {
        
        print("BEGIN: unwindToSettings")
        
        var ret: Bool
        
        if let sourceViewController = sender.source as? OldPasswordViewController,
            let pw = sourceViewController.newPassword,
            let pwh = sourceViewController.newPasswordHint {
            
            print("Back from OldPasswordViewController, password = (\(pw), password hint = \(pwh)")
            
            ret = writePasswordToKeychain(password: pw)
            
            if ret {
                print("Saved password to keychain in settings")
                password = pw
            } else {
                print("Could not save password to keychain in settings")
            }
        
            ret = savePasswordHint(pwh: pwh)

            if ret {
                print("Saved password hint to core data from Settings")
            } else {
                print("Could not write password to core data from settings")
            }
            
            //usePassword = optionUsePassword.isOn
            setUsePassword(usePW: optionUsePassword.isOn)
            
            ret = saveUsePassword(usePW: usePassword!)

            buttonChangePassword.isEnabled = usePassword!
            
            if ret {
                print("Saved use password to core data from Settings")
            } else {
                print("Could not save use password to core data from settings")
            }

        }
    }

    @IBAction func optionUsePassword(_ sender: UISwitch) {
        
        if sender.isOn {
            // show add password
        } else {
            // show turn off password
        }
        
    }
    
    //MARK: Private Functions
    
    @objc private func handleAppDidBecomeActive() {
    
        if globalUsePassword == true {
            self.performSegue(withIdentifier: "ReturnToLoginFromSettings", sender: self)
        }
    }
    
    private func setUsePassword(usePW: Bool) {
    
        usePassword = usePW
        globalUsePassword = usePW
        
    }
    
    private func handleChangePassword(pw: String) {

        if self.password == pw  {
            
            // ok, segue to change password screen
            self.performSegue(withIdentifier: "ChangePassword", sender: self)

        } else {

            // incorrect password do not continue
            
            // show an alert that the password entered was incorrect
            let alert = UIAlertController(title: "", message: "Incorrect Password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
       
       
    }
    
    private func handleTurnOffPassword(pw: String) -> Bool {
        
        var ret: Bool
        
        if self.password == pw {
            
            // ok, allow password feature to be turned off
            //self.usePassword = false
            setUsePassword(usePW: false)

            ret = true
            let r = self.saveUsePassword(usePW: self.usePassword!)
            buttonChangePassword.isEnabled = false
            
        } else {
        
            // no, turn use password feature back on
            setUsePassword(usePW: true)
            self.optionUsePassword.isOn = true
            ret = false
            buttonChangePassword.isEnabled = true
            
            // show an alert that the password entered was incorrect
            let alert = UIAlertController(title: "", message: "Incorrect Password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        return ret
        
    }
    
    private func getVersionAndBuild() -> (String, String) {
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        
        let version = nsObject as! String
        
        let nsObject2: AnyObject? = Bundle.main.infoDictionary!["CFBundleVersion"] as AnyObject
        
        let build = nsObject2 as! String
        
        print("version: \(version), build: \(build)")
        
        return (version, build)
        
    }

    private func getUsePassword() -> Bool {
        
        print("getUsePassword(): BEGIN")
        
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
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            print("deleted all Settings records")
        } catch {
            print("there was an error deleting Settings")
        }
        
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
            print("saved Settings")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            ret = false
        }
        
        print("saveUsePassword(): END")
        
        return ret
        
    }

    private func savePasswordHint(pwh: String) -> Bool {
        
        print("savePasswordHint(): BEGIN")
        
        var ret: Bool = false
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PasswordHint")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            print("deleted all PasswordHint recortds")
        } catch {
            print("there was an error deleting PasswordHint")
        }
        

        // save to Items table
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "PasswordHint", in: managedContext)!
        
        let thisItem = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        thisItem.setValue(pwh, forKeyPath: "password_hint")
        
        // 4
        do {
            try managedContext.save()
            ret = true
            print("saved password_hint")
        } catch let error as NSError {
            print("savePasswordHint(): Could not save. \(error), \(error.userInfo)")
            ret = false
        }
        
        print("savePasswordHint(): END")
        
        return ret
        
    }

}
