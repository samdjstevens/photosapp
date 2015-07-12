//
//  PhotosAPIPostRequest.swift
//  Photos
//
//  Created by Sam Stevens on 12/07/2015.
//  Copyright © 2015 Sam Stevens. All rights reserved.
//

class PhotosAPIPostRequest : PhotosAPIRequest {
    
    init(endPoint: String, requestData: [String: AnyObject]?) {
        super.init(requestMethod: .Post, endPoint: endPoint, requestData: requestData)
    }
}
