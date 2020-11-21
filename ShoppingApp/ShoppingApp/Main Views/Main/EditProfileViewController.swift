//
//  EditProfileViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 21/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserInfo()
    }
    
    
    //MARK: - IBActions
    
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if textFieldsHaveText() {
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADDRESS : addressTextField.text!]
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error == nil {
                    IndicatorManager.shared.showSuccessHUD(with: "Updated!")
                } else {
                    print("error updating user ", error!.localizedDescription)
                    IndicatorManager.shared.showFailureHUD(with: error!.localizedDescription)
                }
            }
            
        } else {
            IndicatorManager.shared.showFailureHUD(with: "All fields are required!")
            
        }
    }
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logOutUser()
    }
    
    
    //MARK: - UpdateUI
    
    private func loadUserInfo() {
        if MUser.currentUser() != nil {
            let currentUser = MUser.currentUser()!
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    //MARK: - Helper funcs
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logOutUser() {
        MUser.logOutCurrentUser { (error) in
            if error == nil {
                print("logged out")
                self.navigationController?.popViewController(animated: true)
            }  else {
                print("error login out ", error!.localizedDescription)
            }
        }
    }
}

