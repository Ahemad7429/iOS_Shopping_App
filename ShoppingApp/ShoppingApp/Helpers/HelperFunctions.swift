//
//  HelperFunctions.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 17/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import Foundation

func convertToCurrency(_ number: Double) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    return currencyFormatter.string(from: NSNumber(value: number))!
}
