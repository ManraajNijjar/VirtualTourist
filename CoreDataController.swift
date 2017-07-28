//
//  CoreDataController.swift
//  VirtualTourist
//
//  Created by Manraaj Nijjar on 7/24/17.
//  Copyright © 2017 Manraaj Nijjar. All rights reserved.
//

import Foundation
import CoreData


class CoreDataController {
    // MARK: - Core Data stack
    
    let apiController = APIController.sharedInstance()
    var pinsList = [Pin]()
    
    
    private init(){
        
    }
    
    class func getContext() -> NSManagedObjectContext {
        return CoreDataController.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func generateCoreDataPin(latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool) -> Void){
        apiController.performFlickPhotoSearch(latitude: String(latitude), longitude: String(longitude), completionHandler: { (data, error) in
            //Completion handler grabs the results from the API search and turns it into Pin data
            // Instantiates a pin
            let pin: Pin = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: CoreDataController.getContext()) as! Pin
            pin.latitude = latitude
            pin.longitude = longitude
            
            guard let photosDictionary = data!["photos"] as? [String:AnyObject] else {
                return
            }
            guard let photosList = photosDictionary["photo"] as? [[String: AnyObject]] else {
                return
            }
            
            //Build each photo object and attach it to the pin
            for photoModel in photosList {
                
                let photo: Photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: CoreDataController.getContext()) as! Photo
                photo.photoURL = photoModel["url_m"] as? String
                pin.addToPhotos(photo)
                photo.pin = pin
            }
            completionHandler(true)
        })
    }
    
    //Fetches the data on all pins from Core Data and returns it in an array
    func fetchAllPins() -> [Pin] {
        //Move this to the core data controller
        var pinsFromFetch = [Pin]()
        
        //Makes the fetch request for pins
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            pinsFromFetch = try CoreDataController.getContext().fetch(fetchRequest)
            print("Number of Results: \(pinsFromFetch.count)")
            
        } catch {
            print(error)
        }
        pinsList = pinsFromFetch
        return pinsFromFetch
    }
    
    func fetchPinForCoords(valueForLongitude: Double, valueForLatitude: Double) -> Pin {
        //var pinForCoords = Pin()
        print(valueForLongitude)
        print(valueForLatitude)
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "longitude == %@", String(valueForLongitude))
        //fetchRequest.predicate = NSPredicate(format: "latitude == %@", valueForLatitude)
        print(fetchRequest.predicate!)
        do {
            //Returns an array of pins so we'll just grab the first value from it
            let results = try CoreDataController.getContext().fetch(fetchRequest)
            print(results.count)
            print(results.first!)
            return results.first!
            
        } catch {
            print(error)
        }
        
        return Pin()
    }
    
    //Generate a Singleton instance of the CoreDataController
    class func sharedInstance() -> CoreDataController {
        struct Singleton {
            static var sharedInstance = CoreDataController()
        }
        return Singleton.sharedInstance
    }
}
