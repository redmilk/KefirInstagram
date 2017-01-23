//
//  FeedViewController.swift
//  MonsterFeed
//
//  Created by Artem on 1/16/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts = [Post]()
    var following = [String]()
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPosts()
    }
    
    //fetchPosts
    func fetchPosts() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as! [String : AnyObject]
            for(_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid == FIRAuth.auth()?.currentUser?.uid {
                        if let followingUsers = value["following"] as? [String : String] {
                            for (_,user) in followingUsers {
                                self.following.append(user)
                            }
                        }
                        self.following.append(FIRAuth.auth()!.currentUser!.uid)
                        //get posts
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            let postsSnap = snap.value as! [String : AnyObject]
                            
                            for(_, post) in postsSnap {
                                if let userID = post["userId"] as? String {
                                    //go through the usersIDs in the 'following'
                                    for each in self.following {
                                        if each == userID {
                                            let postObject = Post()
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let image = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                
                                                postObject.author =  author
                                                postObject.like = likes
                                                postObject.pathToImage = image
                                                postObject.postId = postID
                                                postObject.userId = userID
                                                
                                                if let people = post["peopleWhoLike"] as? [String:AnyObject] {
                                                    for(_, person) in people {
                                                        postObject.peopleWhoLike.append(person as! String) 
                                                    }
                                                }
                                                
                                                self.posts.append(postObject)
                                            }
                                        }
                                    }
                                    
                                    self.collectionView.reloadData()
                                }
                            }
                        })
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    //numberOfSections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return posts.count
    }

    //cellForItemAtindexPath
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PostViewCell
        
        cell.imageView.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likes.text = "\(self.posts[indexPath.row].like!) Likes"
        cell.postID = self.posts[indexPath.row].postId
        
        for person in self.posts[indexPath.row].peopleWhoLike {
            if person == FIRAuth.auth()!.currentUser!.uid {
                cell.likeButton.isHidden = true
                cell.unlikeButton.isHidden = false
                break
            }
        }
        
        
        return cell
    }

}
