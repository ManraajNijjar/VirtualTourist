//
//  APIController.swift
//  VirtualTourist
//
//  Created by Manraaj Nijjar on 7/24/17.
//  Copyright © 2017 Manraaj Nijjar. All rights reserved.
//

import Foundation

class APIController {
    
    let apiKey = "8e8d723c5110ca9adcb358222661a3b9"
    let apiSecret = ""
    var lastPageNum = 0
    
    func performFlickPhotoSearch(latitude: String, longitude: String, refreshPageCount: Int, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        var pageNumber = 1
        
        //The Flickr API will only return a max of 4000 images so pages beyond that will contain the same photos
        //
        if refreshPageCount > 1 && refreshPageCount < 160 {
            pageNumber = Int(arc4random_uniform(UInt32(refreshPageCount)) + 1)
            while pageNumber == lastPageNum {
                pageNumber = Int(arc4random_uniform(UInt32(refreshPageCount)) + 1)
            }
            lastPageNum = pageNumber
        }
        
        if refreshPageCount > 1 && refreshPageCount > 160 {
            pageNumber = Int(arc4random_uniform(160) + 1)
            while pageNumber == lastPageNum {
                pageNumber = Int(arc4random_uniform(160) + 1)
            }
            lastPageNum = pageNumber
        }
        
        let searchUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&page=\(pageNumber)&per_page=25&lat=\(latitude)&lon=\(longitude)&format=json&extras=url_m&nojsoncallback=1"
        print(searchUrl)
        let request = URLRequest(url: URL(string: searchUrl)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard error == nil else {
                //DisplayErrorFunction()
                return
            }
            //Uncasts the data optional
            guard let data = data else {
                return
            }
            //Process the results of the data so it can be accessed like normal JSON data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: { (results, error) in
                if error != nil {
                    completionHandler(nil, error)
                }
                if error == nil {
                    completionHandler(results, nil)
                }
            })
            
        }
        //Determine why API Controller is not getting commited
        task.resume()
        //ohno
    }
    
    //Retrieves the image from the URL
    func retrieveImageData(photoURL: URL, completionHandlerForURL: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        if let imageData = try? Data(contentsOf: photoURL) {
            completionHandlerForURL(imageData as AnyObject, nil)
        } else {
            completionHandlerForURL(nil, nil)
        }
    }
    
    //Convert data to JSON
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    //Generate a Singleton instance of the APIController
    class func sharedInstance() -> APIController {
        struct Singleton {
            static var sharedInstance = APIController()
        }
        return Singleton.sharedInstance
    }
}
