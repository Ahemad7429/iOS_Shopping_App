//
//  ImageCollectionViewCell.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 18/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setUpImage(with image: UIImage) {
        self.imageView.image = image
    }
    
}
