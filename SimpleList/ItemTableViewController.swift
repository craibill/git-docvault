//
//  ItemTableViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 2/22/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit
import CoreData

class ItemTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var itemsdb: [NSManagedObject] = []

    //var currentIndexPathRow = 0
    //var currentFullSizeImage: NSManagedObject?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        //searchController.searchBar.isHidden = false
        
        // use the edit button provided by the table view controller
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    override func viewWillAppear(_ animated: Bool) {
  
        // show the navigation bar and searchbar when this view displays
        self.navigationController?.setToolbarHidden(false, animated: animated)
        searchController.searchBar.isHidden = false
        //searchController.searchBar.showsCancelButton = true
        
        // load the data from the Items table
        let searchText = searchController.searchBar.text ?? ""
        
        getAllItemsData(searchText: searchText)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // dismiss the search bar before moving on to next view
        searchController.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsdb.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ItemTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            
            fatalError("The dequeued cell is not an instance of ItemTableViewCell")
        }

        let itm = itemsdb[indexPath.row]
        let img: NSData? = itm.value(forKey: "thumb_size_image") as? NSData

        // Configure the cell...
        cell.nameLabel.text = itm.value(forKey: "item_description") as? String
        
        // this should be the thumb sized image...
        cell.photoImageView.image = UIImage(data: img as! Data)
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let match = itemsdb[indexPath.row]
            let id = match.value(forKey: "id") as! String
            
            // delete from Items and FullSizeImages
            deleteItemHelper(id: id)
            
            // Delete the row from the data source
            itemsdb.remove(at: indexPath.row)
            
            // delete from table
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchText = searchController.searchBar.text ?? ""

        print("updateSearchResults(): searchText: '\(searchText)'")
        
        getAllItemsData(searchText: searchText)
        tableView.reloadData()

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        getAllItemsData(searchText: "")
        tableView.reloadData()

    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchController.searchBar.isHidden = false

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        //searchController.searchBar.isHidden = true

        
    }
        
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        switch(segue.identifier ?? "") {
        case "AddNew":
            if let index = self.tableView.indexPathForSelectedRow{
                self.tableView.deselectRow(at: index, animated: true)
            }
            
        case "ShowDetail":
            guard let itemDetailViewController = segue.destination as? ItemViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? ItemTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // retreive the data for this item from the itemsdb array
            //currentIndexPathRow = indexPath.row // currentIndexPathRow is used only if editing existing item
            let itm = itemsdb[indexPath.row]
            let item_id = itm.value(forKey: "id") as? String ?? ""
            let item_description = itm.value(forKey: "item_description") as? String ?? ""
            let img: NSData? = itm.value(forKey: "thumb_size_image") as? NSData
            let item_image_thumb = UIImage(data: img! as Data)
            
            // must fetch the full size image from the db directly
            if let currentFullSizeImage = getFullSizedImageObject(item_id: item_id) {

                let match_image_data: NSData? = currentFullSizeImage.value(forKey: "full_size_image") as? NSData
                let fullSizedImage = UIImage(data: match_image_data as! Data)

                print("full sized image found")
                
                guard let item = ItemClass(id: item_id, description: item_description, fullSizeImage: fullSizedImage!, thumbSizeImage: item_image_thumb!) else {
                    fatalError("unable to instantiate ItemClass")
                }
                
                itemDetailViewController.item = item
            
            } else {
                    print("full sized image not found")
            }
            
        case "unwindToLogin":
            //os_log("hopefully return to login", log: OSLog.default, type: .debug)
            searchController.dismiss(animated: true, completion: nil)
            searchController.searchBar.isHidden = true
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
            
        }
        
    }

    //MARK: Actions

    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)

    }
    
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        
        print("BEGIN: unwindToItemList")
        
        searchController.searchBar.isHidden = false

        if let sourceViewController = sender.source as? ItemViewController,
            let item = sourceViewController.item,
            let mode = sourceViewController.mode,
            let descriptionDidChange = sourceViewController.descriptionDidChange,
            let imageDidChange = sourceViewController.imageDidChange {

            // check if a row in the table view is selected
            // it is is then the user tapped one of the table view cells to edit a document
            //if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
            if mode == viewMode.addMode {
                
                // Add a new item
                print("Add a new item:")
                print("item, id: \(item.id), description: \(item.description)")
                
                saveItem(item: item)
                tableView.reloadData()
                
            } else if mode == viewMode.editMode {
                
                // Update an existing item if the description changed or the image changed
                if (descriptionDidChange || imageDidChange) {
                    updateItem(item: item)
                }
                
                // update the image if the image changed
                if imageDidChange {
                    updateFullSizeImage(item: item)
                }
                tableView.reloadData()

            } else {
                
                print("undefined mode returning from ItemViewController")
            
            }

        }
        
        print("END: unwindToItemList")

    }
    
    //MARK: Private Functions
    
    private func getAllItemsData(searchText: String) {
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Items")
        let sort = NSSortDescriptor(key: "item_description", ascending: true)
        fetchRequest.sortDescriptors = [sort]

        if !searchText.isEmpty {
            let predicate = NSPredicate(format: "item_description CONTAINS [c] %@", searchText)
            fetchRequest.predicate = predicate
        }

        do {
            itemsdb = try managedContext.fetch(fetchRequest)
            print("getItemsData(): itemsdb.count: \(itemsdb.count)")
        } catch let error as NSError {
            print("getItemsData(): Could not fetch. \(error), \(error.userInfo)")
        }

    }
    
    private func getFullSizedImageObject(item_id: String) -> NSManagedObject? {
    
        //need to get full size image from fullsizeimage table
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FullSizeImages")
        let predicate = NSPredicate(format: "id == %@", item_id)
        fetchRequest.predicate = predicate
        
        // read to FullSizeImages table
        do
        {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            print("results.count \(results.count)")
            
            if results.count != 0 {
                
                let match = results[0] as! NSManagedObject
                let match_id = match.value(forKey: "id") as! String
                print("item_id: \(item_id), match_id \(match_id)")
                return match
                
            } else {
                print("no results")
            }
        } catch {
            print("not found")
        }
        
        return nil
    }

    /*
    private func getFullSizedImage(item_id: String) -> UIImage? {
        
        //need to get full size image from fullsizeimage table
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FullSizeImages")
        
        let predicate = NSPredicate(format: "id == %@", item_id)
        
        fetchRequest.predicate = predicate
        
        
        // read to FullSizeImages table
        do
        {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            print("results.count \(results.count)")
            
            if results.count != 0 {
                
                let match = results[0] as! NSManagedObject
                
                let match_id = match.value(forKey: "id") as! String
                
                print("item_id: \(item_id), match_id \(match_id)")
                
                let match_image_data: NSData? = match.value(forKey: "full_size_image") as? NSData
                let match_image = UIImage(data: match_image_data as! Data)
                
                return match_image
                //return nil
                
            } else {
                print("no results")
            }
        } catch {
            print("not found")
            
        }
        
        return nil
    }
 
 */
    
    private func saveItem(item: ItemClass) {
        
        var id: String = ""
        var description: String = ""
        var fullSizeImage: UIImage
        var thumbSizeImage: UIImage
        
        id = item.id
        description = item.description
        fullSizeImage = item.image!
        thumbSizeImage = item.imageThumb!
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // save to Items table
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Items",
                                       in: managedContext)!
        
        let thisItem = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        thisItem.setValue(id, forKeyPath: "id")
        thisItem.setValue(description, forKeyPath: "item_description")
        
        // convert the image before saving
        var thumbImageData = UIImageJPEGRepresentation(thumbSizeImage, 1)
        thisItem.setValue(thumbImageData, forKeyPath: "thumb_size_image")
        
        // 4
        do {
            try managedContext.save()

            itemsdb.append(thisItem)

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        // save to FullSizeImages table
        // 2
        let img_entity =
            NSEntityDescription.entity(forEntityName: "FullSizeImages",
                                       in: managedContext)!
        
        let thisImg = NSManagedObject(entity: img_entity,
                                       insertInto: managedContext)
        
        thisImg.setValue(id, forKey: "id")
        // convert the image before saving
        var fullImageData = UIImageJPEGRepresentation(fullSizeImage, 1)
        thisImg.setValue(fullImageData, forKeyPath: "full_size_image")
        
        // 4
        do {
            try managedContext.save()
            //itemsdb.append(thisItem)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
    }
    
    private func deleteItemHelper(id: String) {
        
        deleteItem(id: id)
        deleteFullSizeImage(id: id)
    }
    
    private func deleteItem(id: String) {

        print("BEGIN: deleteItem")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate

        do
        {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            print("fetching from Items: results.count \(results.count)")
            
            if results.count == 1 {
                
                let match = results[0] as! NSManagedObject
                let match_id = match.value(forKey: "id") as! String
                print("id: \(id), match_id \(match_id)")
                
                // delete the record
                managedContext.delete(match)
                
                do {
                    try managedContext.save()
                } catch {
                    print("error \(error)")
                }
                
            } else {
                print("Error: results.count: \(results.count)")
            }
        } catch {
            print("Error while deleting Item")
        }

        print("END: deleteItem")

    }
    
    private func deleteFullSizeImage(id: String) {
        
        print("BEGIN: deleteFullSizeImage")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FullSizeImages")
        let predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.predicate = predicate
        
        do
        {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            print("fetching from FullSizeImages: results.count \(results.count)")
            
            if results.count == 1 {
                
                let match = results[0] as! NSManagedObject
                let match_id = match.value(forKey: "id") as! String
                print("id: \(id), match_id \(match_id)")

                // delete the record
                managedContext.delete(match)
                
                do {
                    try managedContext.save()
                } catch {
                    print("error \(error)")
                }
            } else {
                print("Error: results.count: \(results.count)")
            }
        } catch {
            print("Error while deleting FullSizeImage")
        }
        print("END: deleteFullSizeImage")

    }
    
    private func updateItem(item: ItemClass) {
        
        print("BEGIN: updateItem")
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        let predicate = NSPredicate(format: "id == %@", item.id)
        fetchRequest.predicate = predicate

        do
        {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            print("fetching from Items: results.count \(results.count)")
            
            if results.count == 1 {
                
                let match = results[0] as! NSManagedObject
                let match_id = match.value(forKey: "id") as! String
                print("item_id: \(item.id), match_id \(match_id)")

                // update the description
                match.setValue(item.description, forKey: "item_description")

                // convert the image before saving
                let thumbImageData = UIImageJPEGRepresentation(item.imageThumb!, 1)
                
                // update the thumb image
                match.setValue(thumbImageData, forKeyPath: "thumb_size_image")
                do {
                    try managedContext.save()
                } catch {
                    print("error \(error)")
                }
                
            } else {
                print("Error: results.count: \(results.count)")
            }
        } catch {
            print("Error while updating Item")
        }
        
        print("END: updateItem")
    }

    private func updateFullSizeImage(item: ItemClass) {
        
        print("BEGIN: updateFullSizeImage")

        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FullSizeImages")
        let predicate = NSPredicate(format: "id == %@", item.id)
        fetchRequest.predicate = predicate
        
        do
        {
            let results = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            print("fetching from FullSizeImages: results.count \(results.count)")
            
            if results.count == 1 {
                
                let match = results[0] as! NSManagedObject
                let match_id = match.value(forKey: "id") as! String
                print("item_id: \(item.id), match_id \(match_id)")
                
                // convert the image before saving
                let fullSizeImageData = UIImageJPEGRepresentation(item.image!, 1)
                
                // update the full size image
                match.setValue(fullSizeImageData, forKeyPath: "full_size_image")
                do {
                    try managedContext.save()
                } catch {
                    print("error \(error)")
                }
            } else {
                print("Error: results.count: \(results.count)")
            }
        } catch {
            print("Error while updating Item")
        }
        print("END: updateFullSizeImage")
    }
}
