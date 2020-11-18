//
//  CategoryCollectionViewCell.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 15/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var category: Category! {
        didSet {
            nameLabel.text = category.name
            imageView.image = category.image
        }
    }
    
}
