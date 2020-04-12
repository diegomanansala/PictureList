//
//  Network.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import Foundation

class Network {
    var session: MyURLSession!
    
    func getPhotos(page: Int = 1,
                    limit: Int = 10,
                    completionHandler: @escaping ([Photo]?, Bool?) -> Void) {
        
        session = URLSession.shared
        
        let path = Bundle.main.path(forResource: "Configuration", ofType: "plist")
        let config = NSDictionary(contentsOfFile: path!)
        let access_key = config!.value(forKey: "ACCESS_KEY") as? String

        guard let photosUrl =  URL(string: "https://api.unsplash.com/photos")
            else { fatalError() }
        var photosUrlRequest = URLRequest(url: photosUrl)
        photosUrlRequest.addValue("Client-ID \(access_key ?? "")", forHTTPHeaderField: "Authorization")
        
        
        let task = session.dataTask(with: photosUrlRequest) { (data, response, error) in
            var photos: [Photo] = []
            if let _ = error {
                completionHandler(nil, false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completionHandler(nil, false)
                return
            }
            
            guard let mime = response!.mimeType,
                mime == "application/json" else {
                completionHandler(nil, false)
                return
            }
            
            do {
                if let photosJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any] {
                    for p in photosJson {
                        
                    }
                }
            }  catch let serializationError as NSError {
                print("JSON error: \(serializationError.localizedDescription)")
                completionHandler(nil, false)
            }
            
            completionHandler(photos, true)
        }
        task.resume()
        
//        AF.request(recordsUrl, parameters: params).validate().responseJSON { response in
//            switch response.result {
//                case .success:
//                    completionHandler(response.value,true)
//                case .failure:
//                    completionHandler(nil, false)
//            }
//
//        }
    }
}
