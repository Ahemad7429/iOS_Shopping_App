//
//  Item.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 18/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import Foundation
import InstantSearchClient

class Item {
    
    var id: String!
    var categoryId: String!
    var name: String!
    var description: String!
    var price: Double!
    var imageLinks: [String]!
    
    init() {
    }
    
    init(_dictionary: NSDictionary) {
        
        id = _dictionary[kOBJECTID] as? String
        categoryId = _dictionary[kCATEGORYID] as? String
        name = _dictionary[kNAME] as? String
        description = _dictionary[kDESCRIPTION] as? String
        price = _dictionary[kPRICE] as? Double
        imageLinks = _dictionary[kIMAGELINKS] as? [String]
    }
}

// MARK:- Save Items function

func saveItemsToFireStore(_ item: Item) {
    let id = UUID().uuidString
    item.id = id
    firebaseReference(.Items).document(id).setData(itemDictionaryFrom(item) as! [String: Any])
}

// MARK:- Helper functions

func itemDictionaryFrom(_ item: Item) -> NSDictionary {
    return NSDictionary(objects: [item.id ?? "", item.categoryId ?? "", item.name ?? "", item.description ?? "", item.price ?? 0.0, item.imageLinks ?? []], forKeys: [kOBJECTID as NSCopying, kCATEGORYID as NSCopying, kNAME as NSCopying, kDESCRIPTION as NSCopying, kPRICE as NSCopying, kIMAGELINKS as NSCopying])
}

// MARK:- Download Func

func downloadItemsFromFirebase(withCategoryId: String, completion: @escaping (_ itemsArray: [Item]) -> Void) {
    var itemArray = [Item]()
    firebaseReference(.Items).whereField(kCATEGORYID, isEqualTo: withCategoryId).getDocuments { (snapshot, error) in
        guard let snapshot = snapshot else {
            completion(itemArray)
            return
        }
        if !snapshot.isEmpty {
            for itemDict in snapshot.documents {
                itemArray.append(Item(_dictionary: itemDict.data() as NSDictionary))
            }
        }
        completion(itemArray)
    }
}


func downloadItemsFromFirebase(withIds: [String], completion: @escaping (_ itemsArray: [Item]) -> Void) {
    var itemArray = [Item]()
    var counter = 0
    if withIds.count > 0 {
        for itemId in withIds {
            firebaseReference(.Items).document(itemId).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(itemArray)
                    return
                }
                if snapshot.exists {
                    itemArray.append(Item(_dictionary: snapshot.data()! as NSDictionary))
                    counter += 1
                } else {
                    completion(itemArray)
                }
                if counter == withIds.count {
                    completion(itemArray)
                }
            }
            
        }
    } else {
        completion(itemArray)
    }
}


//MARK: - Algolia Funcs

func saveItemToAlgolia(item: Item) {
    
    let index = AlgoliaServiceManager.shared.index
    
    let itemToSave = itemDictionaryFrom(item) as! [String : Any]
    
    index.addObject(itemToSave, withID: item.id, requestOptions: nil) { (content, error) in
        
        
        if error != nil {
            print("error saving to algolia", error!.localizedDescription)
        } else {
            print("added to algolia")
        }
    }
}

func searchAlgolia(searchString: String, completion: @escaping (_ itemArray: [String]) -> Void) {
    
    let index = AlgoliaServiceManager.shared.index
    var resultIds: [String] = []

    let query = Query(query: searchString)
    query.attributesToRetrieve = ["name", "description"]
    index.search(query) { (content, error) in
        
        if error == nil {
            let cont = content!["hits"] as! [[String : Any]]
            resultIds = []
            for result in cont {
                resultIds.append(result["objectID"] as! String)
            }
            completion(resultIds)
        } else {
            print("Error algolia search ", error!.localizedDescription)
            completion(resultIds)
        }
    }
    
}
