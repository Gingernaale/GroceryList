//
//  GroceryTableViewController.swift
//  GroceryList
//
//  Created by Irunya =} on 04/08/2021.
//

import UIKit
import CoreData

class GroceryTableViewController: UITableViewController {
    
    var groseries = [Grocery]()
    var manageObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        manageObjectContext = appDelegate.persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData () {
        let request: NSFetchRequest <Grocery> = Grocery.fetchRequest()
        do {
            let result = try manageObjectContext?.fetch(request)
            groseries = result!
            tableView.reloadData()
        }catch{
            fatalError("Error in retrieving Grocery items")
        }
    }
    
    func saveData(){
        do{
            try manageObjectContext?.save()
        }catch{
            fatalError("Error in saving Grocery item")
        }
        loadData()
    }
    
    @IBAction func addNewItem(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Grocery Item", message: "What would you like to add?", preferredStyle: .alert)
        alertController.addTextField { textField in
            print(textField)
        }
        
        let addActionButton = UIAlertAction(title: "Add", style: .default) { alertAction in
            let textField = alertController.textFields?.first
            let entity = NSEntityDescription.entity(forEntityName: "Grocery", in: self.manageObjectContext!)
            let grocery = NSManagedObject(entity: entity!, insertInto: self.manageObjectContext)
            
            grocery.setValue(textField?.text, forKey: "item")
            self.saveData()
            //  self.groseries.append(textField!.text!)
            //  self.tableView.reloadData()
            
        } //addAction
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Delete All", message: "Would you like to remove everything?", preferredStyle: .alert)
        
        let addActionButton = UIAlertAction(title: "Delete", style: .default) { alertAction in
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            fetchRequest = NSFetchRequest(entityName: "Grocery")
            let deleteRequest = NSBatchDeleteRequest(
                fetchRequest: fetchRequest
            )
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let context = try managedContext.execute(deleteRequest)
                    as? NSBatchDeleteResult
                guard let deleteResult = context?.result
                        as? [NSManagedObjectID]
                else {
                    return
                }
                
                let deletedObjects: [AnyHashable: Any] = [
                    NSDeletedObjectsKey: deleteResult]
                
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: deletedObjects, into: [])
            } catch {
                print("Items deleted!")
            }
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(addActionButton)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groseries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath)
        
        //  cell.textLabel?.text = groseries[indexPath.row]
        let grocery = groseries[indexPath.row]
        cell.textLabel?.text = grocery.value(forKey: "item") as? String
        cell.accessoryType = grocery.completed ? .checkmark : .none
        return cell
    }
    
    // Mark:- Table view delegate
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            manageObjectContext?.delete(groseries[indexPath.row])
        }
        self.saveData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        groseries[indexPath.row].completed = !groseries[indexPath.row].completed
        self.saveData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "InfoLabel" {
            
            let vc = segue.destination as! InfoViewController
            
            vc.infoLabel = "To add an item, click on Shopping icon in the Navigation Bar.\n Write item name and press add button.\n To delete click on the Trash icon then press delete button."
        }
    }
}
