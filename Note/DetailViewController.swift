import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailNote: UITextView!
    @IBOutlet weak var detailTitle: UITextView!
    
    var choosedTitle = ""
    var choosedUuid : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        if choosedTitle != "" {
            if let uuidString = choosedUuid?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
                
                fetchRequest.predicate = NSPredicate(format:"id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject]{
                            if let title = result.value(forKey: "title") as? String{
                                detailTitle.text = title
                            }
                            
                            if let note = result.value(forKey: "note") as? String{
                                detailNote.text = note
                            }
                            
                            if let image = result.value(forKey: "image") as? Data{
                                let imageData = UIImage(data: image)
                                detailImage.image = imageData
                            }
                        }
                    }
                }catch{
                    print("error")
                }
            }
        }else{
            print("no data")
        }
    }
}
