//
//  ProfileTableViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 21/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var finishRegistrationButton: UIButton!
    @IBOutlet weak var purchaseHistoryButton: UIButton!
    
    // MARK:- Variables
    var editBarButton: UIBarButtonItem!
    
    // MARK:- View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginStatus()
        checkOnboardingStatus()
    }
    
    //MARK: - Helpers
    
    private func checkOnboardingStatus() {
        if MUser.currentUser() != nil {
            if MUser.currentUser()!.onBoard {
                finishRegistrationButton.setTitle("Account is Active", for: .normal)
                finishRegistrationButton.isEnabled = false
            } else {
                finishRegistrationButton.setTitle("Finish registration", for: .normal)
                finishRegistrationButton.isEnabled = true
                finishRegistrationButton.tintColor = .red
            }
            purchaseHistoryButton.isEnabled = true
        } else {
            finishRegistrationButton.setTitle("Logged out", for: .normal)
            finishRegistrationButton.isEnabled = false
            purchaseHistoryButton.isEnabled = false
        }
    }
    
    private func checkLoginStatus() {
        if MUser.currentUser() == nil {
            createRightBarButton(title: "Login")
        } else {
            createRightBarButton(title: "Edit")
        }
    }
    
    
    private func createRightBarButton(title: String) {
        editBarButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(rightBarButtonItemPressed))
        self.navigationItem.rightBarButtonItem = editBarButton
    }
    
    private func showLoginView() {
        let loginView = UIStoryboard.init(name: "Onboarding", bundle: nil).instantiateViewController(identifier: "WelcomeViewController")
        self.present(loginView, animated: true, completion: nil)
    }
    
    private func goToEditProfile() {
        performSegue(withIdentifier: kProfileToEditSeg, sender: nil)
    }
    
    //MARK: - IBActions
    
    @objc func rightBarButtonItemPressed() {
        if editBarButton.title == "Login" {
            showLoginView()
        } else {
            goToEditProfile()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK:- Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


