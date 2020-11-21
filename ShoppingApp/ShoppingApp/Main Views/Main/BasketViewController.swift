//
//  BasketViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 18/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class BasketViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var totalItemLabel: UILabel!
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    
    // MARK:- Variables
    var basket: Basket?
    var purchasedItemIds = [String]()
    var allItems = [Item]()
    
    // MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.tableFooterView = footerView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        } else {
            updateTotalLabels(true)
        }
    }
    
    // MARK:- Actions
    
    @IBAction func checkOutButtonWasTapped(_ sender: UIButton) {
        if MUser.currentUser()!.onBoard {
            tempFunction()
            addItemsToPurchaseHistory(self.purchasedItemIds)
            emptyTheBasket()
        } else {
            IndicatorManager.shared.showFailureHUD(with: "Please complete you profile!")
        }
    }
    
    // MARK:- Download Basket
    
    private func loadBasketFromFirestore() {
        downloadBasketFromFirestore(MUser.currentId()) { (basket) in
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems() {
        if basket != nil {
            downloadItemsFromFirebase(withIds: basket!.itemIds) { (items) in
                self.allItems = items
                self.updateTotalLabels(self.allItems.count == 0)
                self.tableview.reloadData()
            }
        }
    }
    
    func tempFunction() {
        for item in allItems {
            print("we have ", item.id ?? "")
            purchasedItemIds.append(item.id)
        }
    }
    
    
    private func emptyTheBasket() {
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableview.reloadData()
        basket!.itemIds = []
        updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds!]) { (error) in
            if error != nil {
                print("Error updating basket ", error!.localizedDescription)
            }
            self.getBasketItems()
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        if MUser.currentUser() != nil {
            print("item ids , ", itemIds)
            let newItemIds = MUser.currentUser()!.purchasedItemIds + itemIds
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMIDS : newItemIds]) { (error) in
                if error != nil {
                    print("Error adding purchased items ", error!.localizedDescription)
                }
            }
        }
    }
    
    
    // MARK:- Navigation
    
    func showItemView(_ item: Item) {
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ItemViewController") as! ItemViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    // MARK:- Helper Functions
    
    private func updateTotalLabels(_ isEmpty: Bool) {
        if isEmpty {
            totalItemLabel.text = "0"
        } else {
            totalItemLabel.text = "\(allItems.count)"
        }
        basketTotalPriceLabel.text = getBasketTotalPrice()
        checkoutButtonStatusUpdate()
    }
    
    private func getBasketTotalPrice() -> String {
        var totalPrice = 0.0
        allItems.forEach { (item) in
            totalPrice += item.price
        }
        return "Total Price: \(convertToCurrency(totalPrice))"
    }
    
    private func checkoutButtonStatusUpdate() {
        checkOutButton.isEnabled = allItems.count > 0
        if checkOutButton.isEnabled {
            checkOutButton.backgroundColor = #colorLiteral(red: 1, green: 0.4941176471, blue: 0.4745098039, alpha: 1)
        } else {
            checkOutButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }
    
    private func removeItemFromBasket(itemId: String) {
        for i in 0...basket!.itemIds.count {
            if basket!.itemIds[i] == itemId {
                basket!.itemIds.remove(at: i)
                return
            }
        }
    }
    
}

extension BasketViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.item = allItems[indexPath.row]
        return cell
    }
    
    // MARK:- TableView Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = allItems[indexPath.row]
            allItems.remove(at: indexPath.row)
            tableview.reloadData()
            removeItemFromBasket(itemId: itemToDelete.id)
            updateBasketInFirestore(basket!, withValues: [kITEMIDS: basket!.itemIds!]) { (error) in
                if error != nil {
                    print("Error updating the basket", error!.localizedDescription)
                }
            }
            getBasketItems()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        showItemView(allItems[indexPath.row])
    }
}
