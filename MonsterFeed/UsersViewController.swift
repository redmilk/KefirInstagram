//
//  UsersViewController.swift
//  MonsterFeed
//
//  Created by Artem on 1/13/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.retrieveUsers()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    @IBAction func logoutBarButtonHandler(_ sender: UIBarButtonItem) {
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.fullNameLabel.text = self.users[indexPath.row].fullName
        cell.userID = self.users[indexPath.row].userId
        cell.userImage.downloadImage(from: self.users[indexPath.row].picturePath!)
        self.checkFollowing(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        var isFollower = false
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            /// user has followers
            if let following = snapshot.value as? [String : AnyObject] {
                for(ke, value) in following {
                    if value as! String == self.users[indexPath.row].userId {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(self.users[indexPath.row].userId).child("followers/\(ke)").removeValue()
                        
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            /// user has no followers
            if !isFollower {
                let following = ["following/\(key)" : self.users[indexPath.row].userId]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.users[indexPath.row].userId).updateChildValues(followers)
                
                ///vishe bila oshibka, tut dobavlyaet v bazu ne v users, a v root
                //ref.child(self.users[indexPath.row].userId).updateChildValues(followers)
                

                self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        
        ref.removeAllObservers()
    }
    
    
    func checkFollowing(indexPath: IndexPath) {
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            /// user has followers
            if let following = snapshot.value as? [String : AnyObject] {
                for(_, value) in following {
                    if value as! String == self.users[indexPath.row].userId {
                        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    
    func retrieveUsers() {
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String : AnyObject]
            //clear array
            self.users.removeAll()
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    //isklyuchaem nash id
                    if uid != FIRAuth.auth()!.currentUser!.uid {
                         let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullName
                            userToShow.picturePath = imagePath
                            userToShow.userId = uid
                            
                            ///
                            self.users.append(userToShow)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        ref.removeAllObservers()
    }
}

extension UIImageView {
    func downloadImage(from imgURL: String!) {
        
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
           
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }

        })
        task.resume()
    }
}





























