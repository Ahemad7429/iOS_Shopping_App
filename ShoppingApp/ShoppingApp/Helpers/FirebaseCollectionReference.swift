//
//  FirebaseCollectionReference.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 15/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Category
    case Items
    case Basket
}

func firebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
