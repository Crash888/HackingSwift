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
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person ", for: indexPath) as! PersonCell
        
        return cell
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

