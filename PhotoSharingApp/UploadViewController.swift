//
//  UploadViewController.swift
//  PhotoSharingApp
//
//  Created by Macbook on 18.02.2022.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    @objc func chooseImage(){
        let pickerController  = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //seçtiğimiz görseli imageviewe gönderiyoruz.
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        //Referans bize firebasedeki konumunu gösteriyor. Buraya bir dosya oluşturacağım media adında.
        let mediaFolder = storageReferance.child("media")//.child ile medianın altındada bir klasör oluşturabilirim.
        //imageviewı veritabanına eklemek için image'imi bir veriye çevirmem gerek.
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { StorageMetadata, error in
                if error != nil{
                    self.errorMessageShow(title: "Error!", message: error?.localizedDescription ?? "You got an error, please try again")
                }else{
                    imageReferance.downloadURL { url, error in
                        if error == nil{
                            let imageUrl = url?.absoluteString
                            //verilerimizi firestore'a kaydedelim.
                            if let imageUrl = imageUrl {
                                //imageurl opsiyonel olduğu için if kontrolüne sokuyorum
                                let firestoreDatabase = Firestore.firestore()
                                let firestorePost = ["imageUrl": imageUrl, "comment": self.commentTextField.text!, "email": Auth.auth().currentUser!.email as Any, "date": FieldValue.serverTimestamp()] as [String: Any]
                                
                                firestoreDatabase.collection("Post").addDocument(data: firestorePost) { error in
                                    if error != nil {
                                        self.errorMessageShow(title: "Error!", message: error?.localizedDescription ?? "You got an error, please try again")
                                    }else{
                                        //kayıt işlemini yaptıktan sonra chooseimage igeri getirsin yorum satırını temizlesin ve bir önceki feedcontrollera geri dönsün istiyorum.
                                        self.imageView.image = UIImage(named: "chooseimage")
                                        self.commentTextField.text = ""
                                        self.tabBarController?.selectedIndex = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func errorMessageShow(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}
