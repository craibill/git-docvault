//
//  KeychainPasswordUtil.swift
//  SimpleList
//
//  Created by Craig Billings on 5/17/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import Foundation
import CoreData

//Keychain Configuration
struct KeychainConfiguration {
    static let serviceName = "DocVault"
    static let accessGroup: String? = nil
}


func readPasswordFromKeychain() -> String {
    
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

func writePasswordToKeychain(password: String) -> Bool {
    
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

func deletePasswordFromKeychain() -> Bool {
    
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

