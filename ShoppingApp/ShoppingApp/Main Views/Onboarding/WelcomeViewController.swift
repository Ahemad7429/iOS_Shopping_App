//
//  WelcomeViewController.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 19/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resentEmailButton: UIButton!
    
    // MARK:- Variables
    
    
    
    // MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK:- Actions
    
    @IBAction func cancelButtonWasTapped(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func loginButtonWasTapped(_ sender: UIButton) {
        print("Login")
        if textFieldsHaveText() {
            loginUser()
        } else {
            IndicatorManager.shared.showFailureHUD(with: "All fields are required")
        }
    }
    
    @IBAction func signupButtonWasTapped(_ sender: UIButton) {
        print("register")
        if textFieldsHaveText() {
            registerUser()
        } else {
            IndicatorManager.shared.showFailureHUD(with: "All fields are required")
        }
    }
    
    @IBAction func forgotPasswordButtonWasTapped(_ sender: UIButton) {
        if emailTextField.text != "" {
            resetThePassword()
        } else {
            IndicatorManager.shared.showFailureHUD(with: "Please insert email!")
        }
    }
    
    @IBAction func resentEmailButtonWasTapped(_ sender: UIButton) {
        print("resend email")
        MUser.resendVerificationEmail(email: emailTextField.text!) { (error) in
            if error != nil {
                print("error resending email", error?.localizedDescription ?? "")
            }
        }
    }
    
    //MARK: - Helpers
    
    private func resetThePassword() {
        MUser.resetPasswordFor(email: emailTextField.text!) { (error) in
            if error == nil {
                IndicatorManager.shared.showSuccessHUD(with: "Reset password email sent!")
            } else {
                IndicatorManager.shared.showFailureHUD(with: error!.localizedDescription)
            }
        }
    }
    
    //MARK: - Login User
    private func loginUser() {
        IndicatorManager.shared.show()
        MUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            if error == nil {
                if  isEmailVerified {
                    self.dismissView()
                    print("Email is verified")
                } else {
                    IndicatorManager.shared.showFailureHUD(with: "Please Verify your email!")
                    self.resentEmailButton.isHidden = false
                }
                
            } else {
                print("error loging in the iser", error!.localizedDescription)
                IndicatorManager.shared.showFailureHUD(with: error!.localizedDescription)
            }
            IndicatorManager.shared.dismiss()
        }
    }
    
    
    private func registerUser() {
        IndicatorManager.shared.show()
        MUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error == nil {
                IndicatorManager.shared.showSuccessHUD(with: "Varification Email sent!")
            } else {
                print("error registering", error!.localizedDescription)
                IndicatorManager.shared.showFailureHUD(with: error!.localizedDescription)
            }
            IndicatorManager.shared.dismiss()
        }
    }
    
    private func textFieldsHaveText() -> Bool {
        return emailTextField.text != "" && passwordTextField.text != ""
    }
    
    private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
