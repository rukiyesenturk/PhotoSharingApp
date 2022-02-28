//
//  FeedViewController.swift
//  PhotoSharingApp
//
//  Created by Macbook on 18.02.2022.
//

import UIKit
import Firebase
import SDWebImage //Göreseli çekebilmek için

class FeedViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var postDizisi = [Post]()
    /*
    var emailSeries = [String]()
    var commentSeries = [String]()
    var imageSeries = [String]()
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        firebaseGetData()
    }
    func firebaseGetData(){
        let firesoreDatabase = Firestore.firestore()
        firesoreDatabase.collection("Post").order(by: "date", descending: true).addSnapshotListener{(snapshot, error) in
            if error != nil{
                print (error?.localizedDescription as Any)
            } else{
                if snapshot?.isEmpty != true && snapshot != nil{
                    
                    //self.emailSeries.removeAll(keepingCapacity: false)
                    //self.commentSeries.removeAll(keepingCapacity: false)
                    //self.imageSeries.removeAll(keepingCapacity: false)
                    self.postDizisi.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents {
                        //let documentId = document.documentID
                        
                        if let imageUrl = document.get("imageUrl") as? String{
                            //self.imageSeries.append(imageUrl)
                            if let comment = document.get("comment") as? String{
                                //self.commentSeries.append(comment)
                                if let email = document.get("email") as? String{
                                    //self.emailSeries.append(email)
                                    let post  = Post(email: email, comment: comment, imageUrl: imageUrl)
                                    self.postDizisi.append(post)
                                }
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDizisi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.emailText.text = postDizisi[indexPath.row].email
        cell.commentText.text = postDizisi[indexPath.row].comment
        cell.postImageView.sd_setImage(with: URL(string: self.postDizisi[indexPath.row].imageUrl))
        return cell
    }

}
