//
//  PurchasedHistoryTableViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 21/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class PurchasedHistoryTableViewController: UITableViewController {
    
    // MARK: - Variables
    var itemArray : [Item] = []
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadItems()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.item = itemArray[indexPath.row]
        return cell
    }
    
    
    // MARK: - Load items
    
    private func loadItems() {
        downloadItemsFromFirebase(withIds: MUser.currentUser()!.purchasedItemIds) { (allItems) in
            self.itemArray = allItems
            print("we have \(allItems.count) purchased items")
            self.tableView.reloadData()
        }
    }
    
}
