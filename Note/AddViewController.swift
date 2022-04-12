import UIKit
import CoreData

class AddViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var addNote: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var addTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        // close keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // for add image
        addImage.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        view.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc private func closeKeyboard(){
        view.endEditing(true)
    }
    
    @objc private func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // later from choosed image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        addImage.image = info[.cropRect] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let notes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        
        notes.setValue(addTitle.text!, forKey: "title")
        notes.setValue(addNote.text!, forKey: "note")
        
        let imageData = addImage.image?.jpegData(compressionQuality: 0.5)
        notes.setValue(imageData, forKey: "image")
        
        do{
            try context.save()
        }catch{
            print("Error")
        }
        
        // for go to back
        self.navigationController?.popViewController(animated: true)
    }
}
