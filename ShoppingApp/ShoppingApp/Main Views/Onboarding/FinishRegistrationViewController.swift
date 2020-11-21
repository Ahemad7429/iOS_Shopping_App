//
//  FinishRegistrationViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 21/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class FinishRegistrationViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    // MARK: - IBActions
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishiOnboarding()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateDoneButtonStatus()
    }
    
    // MARK: - Helper
    
    private func updateDoneButtonStatus() {
        if nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "" {
            doneButton.backgroundColor =  #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1)
            doneButton.isEnabled = true
        } else {
            doneButton.backgroundColor =  #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            doneButton.isEnabled = false
        }
    }

    private func finishiOnboarding() {
        let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kONBOARD : true, kFULLADDRESS : addressTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error == nil {
                IndicatorManager.shared.showSuccessHUD(with: "Updated!")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error updating user \(error!.localizedDescription)")
                IndicatorManager.shared.showFailureHUD(with: error!.localizedDescription)
            }
        }
    }
}



