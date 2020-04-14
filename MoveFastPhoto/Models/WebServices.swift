//
//  WebServices.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 13/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import Foundation

class WebServices {
    static func loadPhotos(page: Int = 0,
                            per_page: Int = 10,
                            completionHandler: @escaping ([Photo]?, Bool) -> Void) {
        let network = Network.sharedInstance
        network.getPhotos(page: page, per_page: per_page) { (photos, success) in
            if success,
            let photos = photos {
                completionHandler(photos, success)
                return
            }
            
            completionHandler(nil, false)
        }
    }
}
