//
//  SettingViewController.swift
//  PhotoSharingApp
//
//  Created by Macbook on 18.02.2022.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

 
    }
    
    @IBAction func signOutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
        }catch {print ("Error!")}
        
        
    }
    
}
