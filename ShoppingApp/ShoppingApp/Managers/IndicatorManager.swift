//
//  IndicatorManager.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 20/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import Foundation
import JGProgressHUD
import NVActivityIndicatorView

final class IndicatorManager {
    
    static let shared = IndicatorManager()
    
    var window: UIWindow?
    
    private let hud = JGProgressHUD(style: .dark)
    private var activityIdicator: NVActivityIndicatorView?
    
    private init() {
        defaultProperty()
    }
    
    private func defaultProperty() {
        window = (UIApplication.shared.delegate as! AppDelegate).window
        let size = UIScreen.main.bounds
        activityIdicator = NVActivityIndicatorView(frame: CGRect(x: size.width / 2 - 30, y: size.height / 2 - 30, width: 60.0, height: 60.0), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1.0), padding: nil)
    }
    
    func show() {
        if activityIdicator != nil {
            self.window?.addSubview(activityIdicator!)
            activityIdicator?.startAnimating()
        }
    }
    
    func dismiss() {
        if activityIdicator != nil {
            self.activityIdicator?.removeFromSuperview()
            activityIdicator?.stopAnimating()
        }
    }
        func dismiss2() {
        if activityIdicator != nil {
            self.activityIdicator?.removeFromSuperview()
            activityIdicator?.stopAnimating()
        }
    }
    
    func showSuccessHUD(with message: String) {
        guard window != nil else { return }
        self.hud.textLabel.text = message
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.window!)
        self.hud.dismiss(afterDelay: 2.0)
    }
    
    func showFailureHUD(with message: String) {
        guard window != nil else { return }
        self.hud.textLabel.text = message
        self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        self.hud.show(in: self.window!)
        self.hud.dismiss(afterDelay: 2.0)
    }
    
}
