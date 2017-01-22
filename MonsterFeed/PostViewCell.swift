//
//  PostViewCell.swift
//  MonsterFeed
//
//  Created by Artem on 1/16/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit

class PostViewCell: UICollectionViewCell {
   
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var unlikeButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    
    @IBAction func likeButtonHandler(_ sender: UIButton) {
    }
    @IBAction func unlikeButtonHandler(_ sender: UIButton) {
    }
}
