//
//  PhotosAPIRequest.swift
//  Photos
//
//  Created by Sam Stevens on 12/07/2015.
//  Copyright © 2015 Sam Stevens. All rights reserved.
//

import Foundation

class PhotosAPIRequest {
    
    // The base URL of the API
    private let baseURL: String
    
    // The actual request object
    private var request: NSMutableURLRequest!
    
    // The request method type
    private let requestMethod: HTTPRequestMethod
    
    // The endpoint of the API the request will go to
    private let endPoint: String
    
    // The data that will be sent with the request
    private let requestData: [String: AnyObject]?
    
    init(requestMethod: HTTPRequestMethod, endPoint: String, requestData: [String: AnyObject]?) {
        
        // Set the request method, end point and data
        self.requestMethod = requestMethod
        self.endPoint = endPoint
        self.requestData = requestData

        // Fetch the base URL from the Config.plist
        let configPath = NSBundle.mainBundle().pathForResource("Config", ofType: "plist")!
        let config = NSDictionary(contentsOfFile: configPath)!
        self.baseURL = config.valueForKey("PhotosAPIBaseURL") as! String
        
        // Build the request
        buildRequest()
    }
    
    // Convenince intialiser to default the request method to GET
    convenience init(endPoint: String, requestData: [String: AnyObject]?) {
        self.init(requestMethod: .Get, endPoint: endPoint, requestData: requestData)
    }
    
    // Build the NSMutableURLRequest object
    private func buildRequest() {
        
        // Construct the URL
        let requestURL = NSURL(string: "\(baseURL)\(endPoint)")!
        
        // Create the NSMutableRequest object, setting the URL and HTTP request method
        self.request = NSMutableURLRequest(URL: requestURL)
        self.request.HTTPMethod = requestMethod.rawValue
        
        // If there is some request data to send...
        if let theRequestData = requestData {
        
            // Create an encoded key value pair string from the request data dictionary
            let requestDataString = "&".join(theRequestData.map { (key, value) -> String in
                
                let encodedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]"))!
                let encodedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]"))!
                
                return "\(encodedKey)=\(encodedValue)"
            })
  
            
            // Depending on the request method, add the data into
            // the request
            switch self.requestMethod {
                // For GET requests, append the data to the query string of the URL
                case .Get:
                    self.request.URL = NSURL(string: "?\(requestDataString)", relativeToURL: requestURL)
                
                // For all other request methods, send the data string as the body
                default:
                    self.request.HTTPBody = requestDataString.dataUsingEncoding(NSUTF8StringEncoding)
            }
        }
    }

    
    // Send the request to the server
    func send(completion: ([String: AnyObject]?, NSError?) -> Void) {
        

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            // If the request could not be made/the response was invalid, then
            // call the callback with the error
            guard error == nil else {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil, error)
                })
                
                return
            }
            
            
            // Received a response
            do {
                
                // Parse out the JSON data
                
                let responseData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as! [String: AnyObject]
                
                
                // Check for a HTTP status code of anything not 200, and if
                // so call the callback with an error
                if let httpResponse = response as? NSHTTPURLResponse {
                    
                    guard httpResponse.statusCode == 200 else {
                        
                        let responseError = NSError(domain: "PhotosAPIResponseError", code: httpResponse.statusCode, userInfo: responseData)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            completion(nil, responseError)
                        })
                        
                        return
                    }
                }
                
                
                // Request and response are both valid, call the callback with
                // the response data dictionary
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(responseData, nil)
                })
                
                
            } catch {
                
                // The response was not in JSON format, failed to decode
                
                let responseError = NSError(domain: "PhotosAPIInvalidResponseFormatError", code: 0, userInfo: nil)

                // Call the callback with the response error
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(nil, responseError)
                })
            }
        }
        
        // Run the task/send the request
        task!.resume()
    }
 }
