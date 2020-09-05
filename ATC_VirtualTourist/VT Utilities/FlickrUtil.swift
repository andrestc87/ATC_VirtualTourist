//
//  FlickrUtil.swift
//  ATC_VirtualTourist
//
//  Created by andres tello campos on 9/4/20.
//  Copyright © 2020 andres tello campos. All rights reserved.
//

import Foundation
import UIKit

class FlickrUtil {
    
    func downloadedFlickrImageToCell(photo: Photo, dataController: DataController, cell: FlickrCollectionViewCell)  {
        
        URLSession.shared.dataTask(with: URL(string: photo.url!)!) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data!)
                    self.updateFlickrPhotoImageData(photo, imageData: data! as Data, dataController: dataController)
                }
            }
        }
        .resume()
    }
    
    func updateFlickrPhotoImageData(_ photo: Photo, imageData: Data, dataController: DataController) {
        do {
            photo.imageData = imageData
            try dataController.viewContext.save()
        } catch {
            print("Error saving photo.")
        }
    }
}
