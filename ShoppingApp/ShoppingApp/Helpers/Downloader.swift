//
//  Downloader.swift
//  ShoppingApp
//
//  Created by AhemadAbbas on 18/10/20.
//  Copyright © 2020 AhemadAbbas. All rights reserved.
//

import Foundation
import FirebaseStorage

let remoteStorage = Storage.storage()

func uploadImages(images: [UIImage?], itemId: String, completion: @escaping (_ imagesLinks: [String]) -> ()) {
    if Reachabilty.HasConnection() {
        var uploadedImageCount = 0
        var imageLinkArray: [String] = []
        var nameSuffix = 0
        for image in images {
            let fileName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)
            saveImageInFirebase(imageData: imageData!, fileName: fileName) { (imageLink) in
                if imageLink != nil {
                    imageLinkArray.append(imageLink!)
                    uploadedImageCount += 1
                    
                    if uploadedImageCount == images.count {
                        completion(imageLinkArray)
                    }
                }
            }
            nameSuffix += 1
        }
    } else {
        print("No Internet Connection!!")
    }
}

func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> ()) {
    var task: StorageUploadTask!
    let storageRef = remoteStorage.reference(forURL: kFILEREFERENCE).child(fileName)
    
    task = storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
        task.removeAllObservers()
        if error != nil {
            print("Error uploading image", error!.localizedDescription)
            completion(nil)
            return
        }
        
        storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                completion(nil)
                return
            }
            completion(downloadURL.absoluteString)
        }
    })
}


func downloadImages(imageUrls: [String], completion: @escaping (_ images: [UIImage?]) -> Void) {
    var imageArray = [UIImage]()
    var downloadedCounter = 0
    for link in imageUrls {
        let url = NSURL(string: link)
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        downloadQueue.async {
            downloadedCounter += 1
            let data = NSData(contentsOf: url! as URL)
            if data != nil {
                imageArray.append(UIImage(data: data! as Data)!)
                if downloadedCounter == imageUrls.count {
                    DispatchQueue.main.async {
                        completion(imageArray)
                    }
                }
            } else {
                print("Couldn't download images")
            }
        }
    }
    
}
