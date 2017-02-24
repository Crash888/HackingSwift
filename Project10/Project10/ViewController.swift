//
//  ViewController.swift
//  Project10
//
//  Created by D D on 2017-01-22.
//  Copyright © 2017 D D. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    //  When selected throw up an alert box and allow the name to be changed
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, ac] _ in
            let newName = ac.textFields![0]
            person.name = newName.text!
            
            self.collectionView?.reloadData()
        })
        
        present(ac, animated: true)
    }
    
    func addNewPerson() {
        let picker = UIImagePickerController()
        //  Allows user to crop the selected picture
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    //  Image is selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //  Make sure we have an image
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        //  Generate a unique name for the image
        let imageName = UUID().uuidString
        
        //  Get the location to put the new file
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        //  Write the new file to the generated location
        if let jpegData = UIImageJPEGRepresentation(image, 80) {
            try? jpegData.write(to: imagePath)
        }
        
        //  Add a new person to the People array
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView?.reloadData()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //  Get the application documents Directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

