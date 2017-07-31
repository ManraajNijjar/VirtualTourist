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
    
    func performFlickPhotoSearch(latitude: String, longitude: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void){
        let searchUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&per_page=25&lat=\(latitude)&lon=\(longitude)&format=json&extras=url_m&nojsoncallback=1"
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
        let request = URLRequest(url: photoURL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard error == nil else {
                //DisplayErrorFunction()
                completionHandlerForURL(nil, error! as NSError)
                return
            }
            //Get Image
            
            completionHandlerForURL(NSData(), nil)
        }
        
        task.resume()
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
