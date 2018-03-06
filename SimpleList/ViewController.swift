//
//  ViewController.swift
//  SimpleList
//
//  Created by Craig Billings on 2/21/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var people = [PersonClass]()

    var peopledb: [NSManagedObject] = []
    
    var count: Int = 0
    
    // 1
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        loadSampleData()
        
        title = "Simple List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        //tableView.register(UIImage.self, forCellReuseIdentifier: "Image")
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //3
        do {
            peopledb = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in

                                        var newPerson: PersonClass

                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        
                                        guard let imageToSave1 = UIImage(named: "img1") else {
                                            return
                                        }
                                        
                                        guard let imageToSave2 = UIImage(named: "img2") else {
                                            return
                                        }
                                        
                                        guard let imageToSave3 = UIImage(named: "img3") else {
                                            return
                                        }
                                        
                                        guard let imageToSave4 = UIImage(named: "default") else {
                                            return
                                        }
                                        
                                        
                                        self.count = self.count + 1
                                        
                                        if self.count == 1 {
                                            newPerson = PersonClass(name: nameToSave, image: imageToSave1)!
                                            //self.save(name: nameToSave, image: imageToSave1)
                                            
                                        } else if self.count == 2 {
                                            newPerson = PersonClass(name: nameToSave, image: imageToSave2)!
                                            
                                        } else if self.count == 3 {
                                            newPerson = PersonClass(name: nameToSave, image: imageToSave3)!
                                            
                                        } else {
                                            newPerson = PersonClass(name: nameToSave, image: imageToSave4)!
                                            
                                        }
                                        
                                        self.save(person: newPerson)
                                        
                                        //let newPerson = PersonClass(name: nameToSave, image:imageToSave)
                                        
                                        //self.save(name: nameToSave, image: imageToSave)
                                        
                                        //self.people.append(newPerson!)
                                        self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
  
    
    //private func save(name: String, image: UIImage) {
    private func save(person: PersonClass) {

        var name: String = ""
        var image: UIImage
        
        name = person.name
        image = person.imageThumb!
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext

        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Person",
                                       in: managedContext)!
        
        let person = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        person.setValue(name, forKeyPath: "name")
        
        // convert the image before saving
        var newImageData = UIImageJPEGRepresentation(image, 1)
        person.setValue(newImageData, forKeyPath: "image")

        // 4
        do {
            try managedContext.save()
            peopledb.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
*/
    
    private func loadSampleData() {
        
        let photo1 = UIImage(named: "img1")
        let photo2 = UIImage(named: "img2")
        let photo3 = UIImage(named: "img3")
        
        guard let person1 = PersonClass(name: "Harley", image: photo1) else {
            fatalError("unable to instantiate person1")
        }
        guard let person2 = PersonClass(name: "Jason", image: photo2) else {
            fatalError("unable to instantiate person2")
        }
        guard let person3  = PersonClass(name: "Cory", image: photo3) else {
            fatalError("unable to instantiate document3")
        }
        
        people += [person1, person2, person3]
    }
}
    // MARK: - UITableViewDataSource
    extension ViewController: UITableViewDataSource {
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            //return people.count
            return peopledb.count
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
                
                let person = peopledb[indexPath.row]
                
                let cell =
                    tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                  for: indexPath)
                
                cell.textLabel?.text = person.value(forKey: "name") as? String //people[indexPath.row].name
                //let img1 = UIImage(named: "imageHarley")
                let img: NSData? = person.value(forKey: "image") as? NSData
                cell.imageView?.image = UIImage(data: img! as Data)
                
                //cell.imageView?.image = person.value(forKey: "image") as? UIImage //people[indexPath.row].image
                return cell
        }
    }



