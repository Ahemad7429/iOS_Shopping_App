//
//  ItemViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 18/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK:- Variables
    
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    private let secitonInsets = UIEdgeInsets.zero
    private let cellHeight: CGFloat = 196.0
    private let itemsPerRow: CGFloat = 1
    
    // MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        downloadItemPictures()
    }
    
    // MARK:- Helper Functions
    
    func downloadItemPictures() {
        if item != nil && item.imageLinks != nil {
            downloadImages(imageUrls: item.imageLinks) { (images) in
                if images.count > 0 {
                    self.itemImages = images.compactMap { $0 }
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    func setupUI() {
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
        }
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(backTapped))]
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "addToBasket"), style: .plain, target: self, action: #selector(addToBasketTapped))]
    }
    
    func createNewBasket() {
        let newBasket = Basket()
        newBasket.id = UUID().uuidString
        newBasket.ownerId = MUser.currentId()
        newBasket.itemIds = [self.item.id]
        saveBasketToFirestore(newBasket)
        
        hud.textLabel.text = "Added to basket!"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 2)
    }
    
    private func updateBasket(basket: Basket, withValues: [String: Any]) {
        
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2)
                print("Error in update basket", error!.localizedDescription)
            } else {
                self.hud.textLabel.text = "Added to basket!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2)
            }
        }
    }
    
    // MARK:- Actions
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToBasketTapped() {
        if MUser.currentUser() != nil {
            downloadBasketFromFirestore(MUser.currentId()) { (basket) in
                if basket == nil {
                    self.createNewBasket()
                } else {
                    basket!.itemIds.append(self.item!.id)
                    self.updateBasket(basket: basket!, withValues: [kITEMIDS: basket!.itemIds!])
                }
            }
        } else {
                    let welcomeVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        self.present(welcomeVC, animated: true, completion: nil)
        }
    }
}

extension ItemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        if itemImages.count > 0 {
            cell.setUpImage(with: itemImages[indexPath.row])
        }
        return cell
    }
}

extension ItemViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = view.frame.width - secitonInsets.left
        return CGSize(width: availableWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return secitonInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return secitonInsets.left
    }
    
}
