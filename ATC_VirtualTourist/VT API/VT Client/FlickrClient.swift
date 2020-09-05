//
//  FlickrClient.swift
//  ATC_VirtualTourist
//
//  Created by andres tello campos on 9/1/20.
//  Copyright © 2020 andres tello campos. All rights reserved.
//

import Foundation

class FlickrClient {
    
    /* Sample Request
     https://www.flickr.com/services/rest/?
     method=flickr.photos.search&
     api_key=b5625f901b99ec2378ab503d2cbde877&
     lat=32.7123&
     lon=-117.1521&
     format=json&
     nojsoncallback=1
     */
    
    static let flickrClientSharedInstance = FlickrClient()
    
    let flickrApiKey = "33de03aaf9dcd65c57a6908adf8b5f54"
    let flickrSecret = "898b36d7d5d7aeb8"
    let flickrFormat = "json"
    let flickrNoJsonCallback = 1
    let flickrPhotosPerPage = 20
    
    let baseUrl = "https://api.flickr.com/services/rest"
    let searchUrlMethod = "flickr.photos.search"
    
    func getSearchFlickrPhotosUrl(latitude: Double, longitude: Double, page: Int) -> URL? {
        guard var searchUrlComponents = URLComponents(string: baseUrl) else {
            print("Error with the base URL")
            return nil
        }
        
        // Adding all the parameters to the URL
        let method = URLQueryItem(name: "method", value: searchUrlMethod)
        let apiKey = URLQueryItem(name: "api_key", value: flickrApiKey)
        let latitude = URLQueryItem(name: "lat", value: String(latitude))
        let longitude = URLQueryItem(name: "lon", value: String(longitude))
        let format = URLQueryItem(name: "format", value: flickrFormat)
        let noJsonCallback = URLQueryItem(name: "nojsoncallback", value: String(flickrNoJsonCallback))
        let photosPerPage = URLQueryItem(name: "per_page", value: String(flickrPhotosPerPage))
        let page = URLQueryItem(name: "page", value: String(page))
        
        searchUrlComponents.queryItems = [method, apiKey, latitude, longitude, format, noJsonCallback, photosPerPage, page]
        
        guard let searchUrl = searchUrlComponents.url else {
            print("Error creating search url.")
            return nil
        }
        
        return searchUrl
    }
    
    func searchFlickrPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping ([FlickrPhoto]?, Error?) -> Void) {
        let searchFlickrPhotosUrl = getSearchFlickrPhotosUrl(latitude: latitude, longitude: longitude, page: page)
        
        FlickrClient.taskForGETRequest(url: searchFlickrPhotosUrl!, response: FlickrPhotosResponse.self) { (response, error) in
                if let response = response {
                    completion(response.photos?.photo, nil)
                } else {
                    completion(nil, error)
                }
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping(ResponseType?, Error?) -> Void)  -> URLSessionTask{
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                        completion(nil, error)
                }
            }
        }
        
        task.resume()
        
        return task
    }
}
