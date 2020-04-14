//
//  Network.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import Foundation

class Network {
    
    static let sharedInstance = Network()
    
    // We store all ongoing tasks here to avoid duplicating tasks.
    fileprivate var downloadTasks = [String : URLSessionTask]()
    var session: MyURLSession!
    
    func getPhotos(page: Int = 1,
                    per_page: Int = 10,
                    completionHandler: @escaping ([Photo]?, Bool) -> Void) {
        
        session = URLSession.shared
        
        let path = Bundle.main.path(forResource: "Configuration", ofType: "plist")
        let config = NSDictionary(contentsOfFile: path!)
        let access_key = config!.value(forKey: "ACCESS_KEY") as? String

        var photosUrl = URLComponents(string: "https://api.unsplash.com/photos")
        photosUrl?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(per_page)"),
        ]
        
        var photosUrlRequest = URLRequest(url: (photosUrl?.url)!)
        photosUrlRequest.addValue("Client-ID \(access_key ?? "")", forHTTPHeaderField: "Authorization")
        photosUrlRequest.timeoutInterval = 10
        
        let task = session.dataTask(with: photosUrlRequest) { (data, response, error) in
            var photos: [Photo] = []
            
            if page == 1 {
                // consider as refresh
                self.downloadTasks = [String : URLSessionTask]()
            }
            
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
                    for case let p in photosJson {
                        if let photo = Photo(json: p as! [String : Any]) {
                            photos.append(photo)
                        }
                    }
                }
            }  catch let serializationError as NSError {
                print("JSON error: \(serializationError.localizedDescription)")
                completionHandler(nil, false)
            }
            
            completionHandler(photos, true)
        }
        task.resume()
    }
    
    // based on https://andreygordeev.com/2017/02/20/uitableview-prefetching/
    func downloadPhoto(_ fromUrl: URL, key: String, forItemAtIndex: Int? = 0, completionHandler: @escaping (Data?, Bool) -> Void) {
        if let downloadTask = downloadTasks[key],
            downloadTask.state == .completed || (downloadTask.state == .running && downloadTask.originalRequest?.url?.absoluteString == fromUrl.absoluteString) {
            // We're already downloading the image
            return
        }
        
        var downloadUrlRequest = URLRequest(url: fromUrl)
        downloadUrlRequest.timeoutInterval = 10
        
        let task = session.dataTask(with: downloadUrlRequest) { (data, response, error) in
            
            func requestFailed() -> Void {
                self.cancelDownloadingPhoto(key: key)
                completionHandler(nil, false)
            }
            
            if let _ = error {
                requestFailed()
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                requestFailed()
                return
            }
            
            if let data = data {
                completionHandler(data, true)
                return
            }
        }
        
        task.resume()
        self.downloadTasks[key] = task
    }
    
    func cancelDownloadingPhoto(key: String) {

        // Get task with given image id, and cancel it from `tasks` dictionary.
        if let task = downloadTasks[key],
        task.state == .running {
            task.cancel()
            if let _ = downloadTasks.removeValue(forKey: key) {
                print("\(key) removed")
            } else {
                print("\(key) already removed")
            }
            
        }
    }
}
