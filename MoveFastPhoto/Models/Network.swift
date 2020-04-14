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
    fileprivate var downloadTasks = [URLSessionTask]()
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
        
        
        let task = session.dataTask(with: photosUrlRequest) { (data, response, error) in
            var photos: [Photo] = []
            
            if page == 1 {
                // consider as refresh
                self.downloadTasks.forEach { (downloadTask) in
                    downloadTask.cancel()
                }
                self.downloadTasks = []
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
    func downloadPhoto(_ fromUrl: URL, completionHandler: @escaping (Data?, Bool) -> Void) {
        guard self.downloadTasks.firstIndex(where: { $0.originalRequest?.url == fromUrl && ($0.state == .running || $0.state == .completed) }) == nil else {
            // We're already downloading the image.
            return
        }
        
        let task = session.dataTask(with: fromUrl) { (data, response, error) in
            //TODO: Figure out how to handle errors in downloading. Check if URLSessionDataTask can be accessed from completion handler
            
            func requestFailed() -> Void {
                self.cancelDownloadingPhoto(fromUrl)
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
        self.downloadTasks.append(task)
    }
    
    func cancelDownloadingPhoto(_ fromUrl: URL) {

        // Find a task with given URL, cancel it and delete from `tasks` array.
        
        guard let taskIndex = self.downloadTasks.firstIndex(where: { $0.originalRequest?.url == fromUrl }) else {
            return
        }

        let task = downloadTasks[taskIndex]
        task.cancel()
        downloadTasks.remove(at: taskIndex)
    }
}
