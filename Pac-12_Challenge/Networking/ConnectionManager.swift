//
//  ConnectionManager.swift
//  Pac-12_Challenge
//
//  Created by Horacio Alexandro Sanchez on 8/12/21.
//

import Foundation
import UIKit


final class ConnectionManager : NSObject{
    
    /*
        This static class handles connections to the Pac-12 endpoints
    */
    
    static let shared = ConnectionManager()
    fileprivate var handler : (([VODModel]?) -> ())?
    fileprivate var loadedModels = [VODModel]()
    fileprivate var nextPageURL = ""
    
    
    public func fetchVODS(urlString: String, downloadCompletion: @escaping ([VODModel]?) ->()){
        
        /*
            Fetch VOD programs from Pac-12's servers and load a VODModel for each one.
            This function retrieves & creates an array of program dictionaries that's
            use to load VODModels objects. The array of programs is passed to another
            function to handle VODModel loading.
         
            Params [IN]:
            [IN]: urlString - A string representing a Pac-12 endpoint
            [IN]: downloadCompletion - On completion, the VODModels are used to reload the
                  collection view. On failure, an appropiate alert is displayed.
            
            Returns [OUT]:
            [OUT]: N/A

        */
        
        self.handler = downloadCompletion

        //Covert string to URL...
        guard let url = URL(string: urlString) else {
            self.handler?(nil)
            return
        }
        
        //Create request and start a URLSession with data task...
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("aplication/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request, completionHandler: {[weak self] (data, response, error) in
            
            //Check for 200 status code...
            guard let self = self else {return}
            let goodResponses = 200...299
            
            guard let requestResponse = response as? HTTPURLResponse else {
                self.handler?(nil)
                return
            }
            
            if !goodResponses.contains(requestResponse.statusCode){
                self.handler?(nil)
                return
            }
            
            //Unwrap payload ...
            guard let requestData = data else {
                self.handler?(nil)
                return
            }
                        
            do{
                
                //Serialize into dictionaries ...
                let rawJson = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments)
                print(rawJson)

                guard let payloadDictionary = rawJson as? [String : Any] else{
                    self.handler?(nil)
                    return
                }
                
                guard let programsCollection = payloadDictionary[PayloadKeys.Programs.rawValue] as? [[String : Any]] else{
                    self.handler?(nil)
                    return
                }
                guard let nextURL = payloadDictionary[PayloadKeys.NextPage.rawValue] as? String else{
                    self.handler?(nil)
                    return
                }
                
                self.nextPageURL = nextURL
                
                DispatchQueue.global(qos: .userInitiated).async{[weak self] in
                    
                    //Load models in the background ...
                    guard let self = self else {return}
                    self.loadedModels.removeAll()
                    self.loadModel(programs: programsCollection)
                    
                    DispatchQueue.main.async {[weak self] in
                        
                        //Load collection view in the main thread with loaded models ...
                        guard let self = self else {return}
                        self.handler?(self.loadedModels)
                        
                    }//End of DispatchQueue.main
                    
                }//End of DispatchQueue.global

            }catch let caughtError as NSError{
                
                print("\nXXXX Error ocurred while parsing JSON see below:\n" + caughtError.localizedDescription + "\n")
                
            }
                        
        }).resume()
        
        
    }//End of fetchvODS()
    
    
    fileprivate func loadModel(programs: [[String : Any]]){
        
        /*
            Here, I download all metadata for each VOD card (title, schools, duration, etc).
            The fetching & loading dynamic happens serially to ensure this function can
            download all data before loading the models. Once models are loaded for each
            program, they're sent to the main queue where they populate the collection view.
            
         
            Params [IN]:
            [IN]: programs - An array of program dictionaries used to load VODModel objects
            
            Returns [OUT]:
            [OUT]: N/A

        */
                
        //Set up placeholder & helpers ...
        let m = programs.count
        let dispatchModelGroup = DispatchGroup()
        let emptyDictArray = [[String : Any]]()
        let placeholderConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: UIImage.SymbolWeight.light, scale: UIImage.SymbolScale.small)
        let placeholderImage = UIImage(systemName: "questionmark.square.dashed", withConfiguration: placeholderConfig)
        
        //Load a model for each program...
        for i in 0..<m{
            
            print("\n-----Started loading program #\(i+1)")
            let current : [String : Any] = programs[i]
                        
            dispatchModelGroup.enter()
            
            //Get metadata and prepare to load VODModel objects ...
            guard let duration = current[PayloadKeys.VODDuration.rawValue] as? TimeInterval else {return}
            guard let imageDictionary = current[PayloadKeys.Images.rawValue] as? [String : Any] else {return}
            guard let title = current["title"] as? String else {return}
            guard let thumbnailImageUrlString = imageDictionary[PayloadKeys.MediumImageSize.rawValue] as? String else {return}
            let schoolsDictionary = current[PayloadKeys.VODSchools.rawValue] as? [[String : Any]] ?? emptyDictArray
            let sportsDictionary = current[PayloadKeys.VODSports.rawValue] as? [[String : Any]] ?? emptyDictArray
            let schoolIDs = schoolsDictionary.map({$0[PayloadKeys.ItemID.rawValue]}) as! [Int]
            let sportsIDs = sportsDictionary.map({$0[PayloadKeys.ItemID.rawValue]}) as! [Int]
            var schoolCrestURLs = [String]()
            var sportIconURLs = [String]()
            var schoolsNames = [String]()
            var sportsNames = [String]()
            var schoolCrestImages = [UIImage]()
            var sportIconImages = [UIImage]()

            var thumbnailImage = placeholderImage
            
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                
                //Query data from Pac-12's servers in the background ...
                guard let self = self else {return}
                                
                thumbnailImage = self.loadImageWithStringURL(urlStrings: [thumbnailImageUrlString]).first ?? placeholderImage
                (schoolsNames,schoolCrestURLs) = self.loadSchoolNamesAndCrestURLs(ids: schoolIDs)
                (sportsNames,sportIconURLs) = self.loadSportsNamesAndIconURLs(ids: sportsIDs)
                schoolCrestImages = self.loadImageWithStringURL(urlStrings: schoolCrestURLs)
                sportIconImages = self.loadImageWithStringURL(urlStrings: sportIconURLs)
                
                dispatchModelGroup.leave()
                
                DispatchQueue.main.async {[weak self] in
                    
                    //Load models in the main thread ...
                    guard let self = self else {return}
                    var model = VODModel()
                    model.duration = duration
                    model.thumbnailImage = thumbnailImage
                    model.schoolNames = schoolsNames
                    model.sportNames = sportsNames
                    model.title = title
                    model.schoolImages = schoolCrestImages
                    model.sportIcons = sportIconImages
                    model.nextPageURL = self.nextPageURL
                    self.loadedModels.append(model)

                }//End of DispatchQueue.main
                
            }//End of DispatchQueue.global
            
            dispatchModelGroup.wait()
            
        }//End of loop
                
    }//End of loadModel()
    
    
    
    fileprivate func loadSchoolSeals(urlStrings: [String]) -> [UIImage]{
        
        /*
            This function loads a school crest image for each url string
            passed in.
            
         
            Params [IN]:
            [IN]: urlStrings - An array of string urls pointing to school crest images
                               in Pac-12's servers
            
            Returns [OUT]:
            [OUT]: An array of school crest images

        */
        
        //Prepare to download images ...
        let dispatchModelGroup = DispatchGroup()
        var images = [UIImage]()
        var currentImage = UIImage()
        let n = urlStrings.count
        var i = 0
        
        //Exit early if no urls were given ...
        if urlStrings.isEmpty{
            return images
        }
        
        print("+++++Image to download \(n)\n")
        
        //Download and image for each url ...
        for url in urlStrings{
            
            dispatchModelGroup.enter()
            print("Started image 💿 #\(i)")
            self.callPac12Imagery(urlString: url, callCompletion: {(loadedImage) in
                currentImage = loadedImage
                dispatchModelGroup.leave()
            })
            //Save downloaded image ...
            images.append(currentImage)
            dispatchModelGroup.wait()
            i += 1
            
        }
        
        return images
        
    }//end of loadSchoolNames()
    

    
    fileprivate func loadSchoolNamesAndCrestURLs(ids: [Int]) -> (schoolNames:[String], crestURLs:[String]){
        
        /*
            This function retrieves school names and crests' urls for each school
            ID passed in. The strings are stored in their respective arrays and
            returned as a tuple.
            
         
            Params [IN]:
            [IN]: ids - A string array of school IDs queried from  Pac-12's servers.
            
            Returns [OUT]:
            [OUT]: A tuple containing string arrays of school names & crests urls
                   for each school ID

        */
        
        //Prepare to hit Pac-12's servers...
        let dispatchModelGroup = DispatchGroup()
        var names = [String]()
        var urls = [String]()
        var currentName : String?
        var currentURL : String?
        var i = 0
        
        //Exit early if no IDs were given ...
        if ids.isEmpty{
            return (names,urls)
        }
                
        //Retrieve school names and crests' urls for each ID...
        for id in ids{
            
            dispatchModelGroup.enter()
            print("Started Request #\(i)")
            let urlString = "http://api.pac-12.com/v3/schools/\(id)"
            self.callPac12(urlString: urlString, key: PayloadKeys.VODSchools.rawValue, callCompletion: { (name,crestURL) in
                currentName = name
                currentURL = crestURL
                dispatchModelGroup.leave()
            })
            //Save data data...
            dispatchModelGroup.wait()
            names.append(currentName ?? "Unknown School")
            urls.append(currentURL ?? "")
            i += 1
        }
                
        return (names,urls)
        
    }//end of loadSchoolNamesAndCrestURLs()
    
    
    fileprivate func loadSportsNamesAndIconURLs(ids: [Int]) -> (sportNames:[String], iconURLs:[String]){
        
        /*
            This function retrieves sport names and icon' urls for each school
            ID passed in. The strings are stored in their respective arrays and
            returned as a tuple.
            
         
            Params [IN]:
            [IN]: ids - A string array of sport IDs queried from  Pac-12's servers.
            
            Returns [OUT]:
            [OUT]: A tuple containing string arrays of sport names & crests urls
                   for each school ID

        */
        
        //Prepare to hit Pac-12's servers...
        let dispatchModelGroup = DispatchGroup()
        var names = [String]()
        var urls = [String]()
        var currentName : String?
        var currentURL : String?
        var i = 0
        
        //Exit early if no IDs were given ...
        if ids.isEmpty{
            return (names,urls)
        }
                
        //Retrieve sport names and icons' urls for each ID...
        for id in ids{
            dispatchModelGroup.enter()
            print("Started Request #\(i)")
            let urlString = "http://api.pac-12.com/v3/sports/\(id)"
            self.callPac12(urlString: urlString, key: PayloadKeys.VODSports.rawValue, callCompletion: { (name,crestURL) in
                currentName = name
                currentURL = crestURL
                dispatchModelGroup.leave()
            })
            //Save data data...
            dispatchModelGroup.wait()
            names.append(currentName ?? "Unknown School")
            urls.append(currentURL ?? "")
            i += 1
            
        }
        
        return (names,urls)
        
    }//end of loadSchoolNames()
    
    
    fileprivate func callPac12(urlString: String, key: String, callCompletion: @escaping (String,String) -> ()){
        
        /*
            This function is used to retrieve names & image urls for both schools & sports
            for a given endpoint. It queries Pac-12's servers for these fields and completes
            according to the endpoint used in the query.
            
         
            Params [IN]:
            [IN]: urlString - A string url representing either a school or sport endpoint
            [IN]: key - A string key letting URLSession know whether the endpoint is school
                        or sport.
            [IN]: callCompletion - On completion, the items retrieves are saved.

         
            Returns [OUT]:
            [OUT]: N/A

        */
        
        //Construct request from endpoint string and start URLSession ...
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("aplication/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            //Unwrap payload ...
            guard let requestData = data else {return}
                            
            do{
                //Serialize payload into dictionaries...
                let rawJson = try JSONSerialization.jsonObject(with: requestData, options: .allowFragments)
                print(rawJson)
                guard let payloadDictionary = rawJson as? [String : Any] else {return}
                guard let itemName = payloadDictionary[PayloadKeys.ItemName.rawValue] as? String else {return}
                
                
                if key == PayloadKeys.VODSchools.rawValue{
                    
                    //School enpoint was called. Complete accordingly ...
                    guard let imagesDictionary = payloadDictionary[PayloadKeys.Images.rawValue] as? [String : Any] else {
                        callCompletion(itemName,"")
                        return
                    }
                    guard let crestURL = imagesDictionary[PayloadKeys.TinyImageSize.rawValue] as? String else {
                        callCompletion(itemName,"")
                        return
                    }
                    
                    callCompletion(itemName,crestURL)
                    
                }else{
                    
                    //Sport enpoint was called. Complete accordingly ...
                    guard let sportsIconDictionary = payloadDictionary[PayloadKeys.SportIcon.rawValue] as? [String : Any] else {
                        callCompletion(itemName,"")
                        return
                    }
                    guard let iconURL = sportsIconDictionary[PayloadKeys.TinyImageSize.rawValue] as? String else {
                        callCompletion(itemName,"")
                        return
                    }
                    
                    callCompletion(itemName,iconURL)
                    
                }

            }catch let caughtError as NSError{
                
                print("\nXXXX Error ocurred while parsing JSON see below:\n" + caughtError.localizedDescription + "\n")

            }

        }).resume()
        
    }//End of callPac12()
    
    
    fileprivate func loadImageWithStringURL(urlStrings: [String]) -> [UIImage]{
        
        /*
            This function loads a school crest image for each url string
            passed in.
            
         
            Params [IN]:
            [IN]: urlStrings - An array of string urls pointing to school crest images
                               in Pac-12's servers
            
            Returns [OUT]:
            [OUT]: An array of school crest images

        */
        
        //Prepare to download images ...
        let placeholderConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: UIImage.SymbolWeight.light, scale: UIImage.SymbolScale.medium)
        let placeholderImage = UIImage(systemName: "questionmark.square.dashed", withConfiguration: placeholderConfig)
        let dispatchModelGroup = DispatchGroup()
        var images = [UIImage]()
        var i = 0
        
        //Exit early if no urls were given ...
        if urlStrings.isEmpty{
            return images
        }
                
        //Download and image for each url ...
        for url in urlStrings{
            
            if url == ""{
                images.append(placeholderImage ?? UIImage())
                continue
            }
            
            dispatchModelGroup.enter()
            print("Started image 💿 #\(i)")
            
            self.callPac12Imagery(urlString: url, callCompletion: {(loadedImage) in
                //Save downloaded image ...
                images.append(loadedImage)
                dispatchModelGroup.leave()
            })
            
            dispatchModelGroup.wait()
            i += 1
        }
        
        return images
        
    }//End of loadImageWithStringURL()
    
    
    
    fileprivate func callPac12Imagery(urlString: String, callCompletion: @escaping (UIImage) -> ()){
        
        /*
            This function is used to retrieve images for a fiven url. It queries Pac-12's
            servers for these fields and completes according to the url used in the query.
            
         
            Params [IN]:
            [IN]: urlString - A string url representing pointing to an image in Pac-12's servers
            [IN]: callCompletion - On completion, save image.

         
            Returns [OUT]:
            [OUT]: N/A

        */
        
        //Construct request from endpoint string and start URLSession ...
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("aplication/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            //Unwrap payload & load image...
            guard let imageData = data else {return}
            let loadedImage = UIImage(data: imageData) ?? UIImage()
            
            callCompletion(loadedImage)

        }).resume()
        
    }//End of loadImageWithStringURL()
    
    
}
