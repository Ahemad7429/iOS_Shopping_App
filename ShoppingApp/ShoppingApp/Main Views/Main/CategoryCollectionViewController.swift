//
//  CategoryCollectionViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 15/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class CategoryCollectionViewController: UICollectionViewController {
    
    // MARK:- Variables
    
    var categoryArray = [Category]()
    private let secitonInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    private let itemsPerRow: CGFloat = 3
    
    // MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCategories()
    }

    // MARK:- Functions
    
    // Prepare Data
    private func loadCategories() {
        downloadCategoriesFromFirebase { (allCategories) in
            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }
    }
    
    // Prepare Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kCategoryToItemSeg {
            let vc = segue.destination as! ItemsTableViewController
            vc.category = sender as? Category
        }
    }

}

extension CategoryCollectionViewController {
    
    // MARK:- Collection View Datasource Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        cell.category = categoryArray[indexPath.row]
        return cell
    }
    
    // MARK:- Collection View Delegate Methods
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: kCategoryToItemSeg, sender: categoryArray[indexPath.row])
    }
}

extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = 1 + secitonInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return secitonInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return secitonInsets.left
    }
    
}
