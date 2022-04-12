import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var notes = [String]()
    private var notesUuids = [UUID]()
    
    private var chooseTitle = ""
    private var chooseUuid : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        tableView.dataSource = self
        
        // add botton to navigatinbar
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(toAddVC))
        
        // get data from core data
        getDataFromCoreData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()
        tableViewCell.textLabel?.text = notes[indexPath.row]
        return tableViewCell
    }
    
    // click and go to DetaiViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chooseTitle = notes[indexPath.row]
        chooseUuid = notesUuids[indexPath.row]
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    // for delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
            
            let uuidString = notesUuids[indexPath.row].uuidString
            
            //filter
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == notesUuids[indexPath.row] {
                                context.delete(result)
                                
                                notes.remove(at: indexPath.row)
                                notesUuids.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                            }
                        }
                    }
                }
            }catch{
                print("error")
            }
        }
    }
    
    // send data to other ViewControleller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.choosedTitle = chooseTitle
            destinationVC.choosedUuid = chooseUuid
        }
    }
    
    // go to AddViewController
    @objc private func toAddVC(){
        performSegue(withIdentifier: "toAdd", sender: nil)
    }
    
    private func getDataFromCoreData(){
        
        notes.removeAll(keepingCapacity: false)
        notesUuids.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let title = result.value(forKey: "title") as? String{
                        notes.append(title)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        notesUuids.append(id)
                    }
                }
                tableView.reloadData()
            }
        }catch{
            print("error")
        }
    }
}

