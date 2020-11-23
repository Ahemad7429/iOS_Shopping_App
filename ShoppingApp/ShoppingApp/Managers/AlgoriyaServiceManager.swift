//
//  AlgoriyaServiceManager.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 23/11/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import Foundation
import InstantSearchClient


final class AlgoliaServiceManager {
    
    static let shared = AlgoliaServiceManager()
    
    let client = Client(appID: kALGORIYA_APP_ID, apiKey: kALGORIYA_ADMIN_KEY)
    let index = Client(appID: kALGORIYA_APP_ID, apiKey: kALGORIYA_ADMIN_KEY).index(withName: "item_name")
    
    private init() {}
    
}
