//
//  PostViewCell.swift
//  MonsterFeed
//
//  Created by Artem on 1/16/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

class PostViewCell: UICollectionViewCell {
    
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var unlikeButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    var postID: String!
    
    @IBAction func likeButtonHandler(_ sender: UIButton) {
        self.likeButton.isEnabled = false
        let ref = FIRDatabase.database().reference()
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            //post properties like peopleWhoLike etc.
            if let postSnapshot = snapshot.value as? [String : AnyObject] {
                let updateLikes: [String : Any] = ["peopleWhoLike/\(keyToPost)":FIRAuth.auth()!.currentUser!.uid]
                ref.child("posts").child(self.postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    
                    if error == nil {
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                            if let posttSnapshot = snap.value as? [String : AnyObject] {
                                if let likes = posttSnapshot["peopleWhoLike"] as? [String : AnyObject] {
                                    let likesCount = likes.count
                                    self.likes.text = "\(likesCount) Likes"
                                    
                                    let update = ["likes" : likesCount]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                    
                                    self.likeButton.isHidden = true
                                    self.unlikeButton.isHidden = false
                                    self.likeButton.isEnabled = true
                                }
                                
                            }
                        })
                    }
                    
                })
            }
        })
        ref.removeAllObservers()
    }
    
    @IBAction func unlikeButtonHandler(_ sender: UIButton) {
        self.unlikeButton.isEnabled = false
        let ref = FIRDatabase.database().reference()
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let postProperties = snapshot.value as? [String : AnyObject] {
                if let peopleWhoLike = postProperties["peopleWhoLike"] as? [String : AnyObject] {
                    for(id, person) in peopleWhoLike {
                        if person as? String == FIRAuth.auth()!.currentUser!.uid {
                            ref.child("posts").child(self.postID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                                        
                                        if let postProperties_ = snap.value as? [String : AnyObject] {
                                            if let peopleWhoLike_ = postProperties_["peopleWhoLike"] as? [String : AnyObject] {
                                                let likesCount = peopleWhoLike_.count
                                                self.likes.text = "\(likesCount) Likes"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : likesCount])
                                            } else {
                                                self.likes.text = "0 Likes"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                }
                            })
                            self.likeButton.isHidden = false
                            self.unlikeButton.isHidden = true
                            self.unlikeButton.isEnabled = true
                            break
                        }
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
}







