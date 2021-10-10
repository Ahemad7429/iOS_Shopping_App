//
//  ItemTableViewCell.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 17/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var item: Item? {
        didSet {
            nameLabel.text = item?.name
            descriptionLabel.text = item?.description
            priceLabel.text = convertToCurrency(item?.price ?? 0)
            priceLabel.adjustsFontSizeToFitWidth = true
            if item?.imageLinks != nil && item?.imageLinks.count ?? 0 > 0 {
                downloadImages(imageUrls: [item!.imageLinks.first!]) { (images) in
                    self.itemImageView.image = images.first as? UIImage
                }
            }
        }
    }
    
}
