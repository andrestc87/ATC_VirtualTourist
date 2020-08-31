//
//  FlickrPhotosResponse.swift
//  ATC_VirtualTourist
//
//  Created by andres tello campos on 8/30/20.
//  Copyright © 2020 andres tello campos. All rights reserved.
//

import Foundation

struct FlickrPhotosResponse: Codable {
    let photos: FlickrPhotos?
    let stat: String?
    
    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case stat = "stat"
    }
}

struct FlickrPhotos: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: String?
    let photo: [FlickrPhoto]?
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case photo = "photo"
    }
}

struct FlickrPhoto: Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "owner"
        case secret = "secret"
        case server = "server"
        case farm = "farm"
        case title = "title"
        case ispublic = "ispublic"
        case isfriend = "isfriend"
        case isfamily = "isfamily"
    }
}
