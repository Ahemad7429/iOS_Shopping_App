//
//  ItemsTableViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 18/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift

class ItemsTableViewController: UITableViewController {
    
    // MARK:- Variables
    var category: Category?
    
    var itemArray: [Item] = []

    // MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        self.title = category?.name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if category != nil {
            loadItems()
        }
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kItemToAddItemSeg {
            let vc = segue.destination as! AddItemViewController
            vc.category = category!
        }
    }
    
    func showItemView(_ item: Item) {
        let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ItemViewController") as! ItemViewController
        itemVC.item = item
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    // MARK:- Load Items
    
    func loadItems() {
        downloadItemsFromFirebase(withCategoryId: category!.id) { (items) in
            self.itemArray = items
            self.tableView.reloadData()
        }
    }
    
}

extension ItemsTableViewController {
    
    // MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        cell.item = itemArray[indexPath.row]
        return cell
    }
    
    // MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(itemArray[indexPath.row])
    }
}

extension ItemsTableViewController: EmptyDataSetSource, EmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "No items to display!")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "emptyData")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString(string: "Please check back later.")
    }
}
