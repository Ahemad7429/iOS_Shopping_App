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
    
    var environment : String = PayPalEnvironmentNoNetwork {
        willSet (newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    var payPalConfig = PayPalConfiguration()
    
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
            
            payButtonPressed()
//            tempFunction()
//            addItemsToPurchaseHistory(self.purchasedItemIds)
//            emptyTheBasket()
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
    
    //MARK: - Paypal
    
    private func setupPayPal() {
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "ShoppingApp iOS"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .both
    }
    
    private func payButtonPressed() {
        var itemsToBuy : [PayPalItem] = []
        for item in allItems {
            let tempItem = PayPalItem(name: item.name, withQuantity: 1, withPrice: NSDecimalNumber(value: item.price), withCurrency: "USD", withSku: nil)
            purchasedItemIds.append(item.id)
            itemsToBuy.append(tempItem)
        }
        let subTotal = PayPalItem.totalPrice(forItems: itemsToBuy)
        //optional
        let shippingCost = NSDecimalNumber(string: "50.0")
        let tax = NSDecimalNumber(string: "5.00")
        let paymentDetails = PayPalPaymentDetails(subtotal: subTotal, withShipping: shippingCost, withTax: tax)
        let total = subTotal.adding(shippingCost).adding(tax)
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Payment to ShoppingAppiOS", intent: .sale)
        payment.items = itemsToBuy
        payment.paymentDetails = paymentDetails
        if payment.processable {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        } else {
            print("Payment not processable")
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


extension BasketViewController : PayPalPaymentDelegate {
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("paypal payment cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        paymentViewController.dismiss(animated: true) {
            self.addItemsToPurchaseHistory(self.purchasedItemIds)
            self.emptyTheBasket()
        }
    }
}



