//
//  TestTableViewController.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class PhotoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
    

    var photoTableView : PhotoTableView!
    lazy var refreshControl : UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull down to refresh")
        return refreshControl
    }()
    var isLoading = false
    var isInitialLoading = true
    var photos : [Photo] = []
    var phoneWidth: CGFloat!
    var imageHeight: CGFloat!
    var thumbnailParams: String!
    var page = 1
    var isLoadingMore = false
    
    let cellReuseIdentifier = "photoCellViewReuseIdentifier"
    let per_page = 10
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneWidth = UIScreen.main.bounds.width
        imageHeight = round(phoneWidth * 0.55)
        thumbnailParams = ["q": "80", // compression quality when using lossy file formats
             "fm": "jpg", // image format
             "crop": "entropy", // crop mode
             "cs": "tinysrgb",
             "dpr": "2", // device pixel ratio
             "fit": "crop", // resize fit mode
             "h": "\(Int(imageHeight!))", // height
             "w": "\(Int(phoneWidth!))"] // width
            .map({ (k,v) in "\(k)=\(v)"  }).joined(separator: "&")
        
        
        // instantiate the table
        photoTableView = UINib(nibName: "PhotoTableView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PhotoTableView
        
        // set table delegate and data source
        photoTableView.dataSource = self
        photoTableView.delegate = self
        photoTableView.prefetchDataSource = self
        photoTableView.refreshControl = refreshControl
        
        // Register custom table view cell
        let photoTableViewCellNib = UINib(nibName: "PhotoTableViewCell", bundle: nil)
        photoTableView.register(photoTableViewCellNib, forCellReuseIdentifier: cellReuseIdentifier)
        
        self.title = "Photos"
        self.view = photoTableView
        
        self.refreshTable()
    }
    
    func refreshTable(completionHandler: (() -> Void)? = nil) {
        
        WebServices.loadPhotos(page: 1, per_page: self.per_page) { (results, success) in
            self.page = 1
            if self.isInitialLoading {
                self.isInitialLoading = false
            }
            
            func finishedLoading() {
                self.photoTableView.reloadData()
                completionHandler?()
            }
            
            if success {
                if let results = results {
                    DispatchQueue.global().async {
                        self.photos = results
                        DispatchQueue.main.async {
                            finishedLoading()
                            return
                        }
                    }
                } else {
                    DispatchQueue.global().async {
                        self.photos = []
                        DispatchQueue.main.async {
                            finishedLoading()
                            return
                        }
                    }
                }
            } else {
                DispatchQueue.global().async {
                    self.photos = []
                    DispatchQueue.main.async {
                        finishedLoading()
                        return
                    }
                }
            }
        }
    }
    
    func loadMoreData() {
        if !self.isLoadingMore {
            self.isLoadingMore = true
            
            WebServices.loadPhotos(page: self.page + 1, per_page: self.per_page) { (results, success) in
                if success,
                let results = results {
                    self.page = self.page + 1
                    DispatchQueue.global().async {
                        self.photos += results
                        DispatchQueue.main.async {
                            self.photoTableView.reloadData()
                            return
                        }
                    }
                }
            }
            
//            let page = self.page + 1
//            WebServices.loadRecords(offset: offset, limit: self.limit, refresh: false) { (success) in
//                let moreCookingRecords = self.loadCookingRecords(offset: offset, limit: self.limit)
//
//                if moreCookingRecords.count > 0 {
//                    // only reload the table if there are new entries
//                    self.cookingRecords += moreCookingRecords
//                    self.cookingRecordTableView.cookingRecordTable.reloadData()
//                } else if (moreCookingRecords.count == 0 && self.isAtBottom(self.cookingRecordTableView.cookingRecordTable)) {
//                    // calculate Y of last cell before the loading cell
//                    let scrollToY = self.cookingRecordTableView.cookingRecordTable.contentSize.height - self.cookingRecordTableView.cookingRecordTable.frame.size.height - 55.0
//
//                    // scroll up to last cell before the loading cell to avoid continually calling loadMoreData
//                    self.cookingRecordTableView.cookingRecordTable.setContentOffset(CGPoint(x: 0.0, y: scrollToY), animated: true)
//                }
//                self.isLoadingMore = false
//            }
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        if !self.isLoading {
            self.isLoading = true
            self.refreshTable {
                DispatchQueue.global().async {
                    self.isLoading = false
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return imageHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return imageHeight
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if photos.count == 0 {
            if self.isInitialLoading {
                self.photoTableView.displayLoadingIndicator()
            } else {
                self.photoTableView.setEmptyMessage("No Photos available. Please pull down to refresh.")
            }
        } else {
            self.photoTableView.restore()
        }

        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PhotoTableViewCell
        
        if let imageView = photoTableViewCell.photo {
            if let image = self.photos[indexPath.row].image {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            } else {
                imageView.image = nil
                self.getImage(forItemAtIndex: indexPath.row)
            }
        }
        
        return photoTableViewCell
    }
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetchRowsAt \(indexPaths)")
        indexPaths.forEach { (idxPath) in
            self.getImage(forItemAtIndex: idxPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("cancelPrefetchingForRowsAt \(indexPaths)")
        indexPaths.forEach { (idxPath) in
            self.cancelGetImage(forItemAtIndex: idxPath.row)
        }
    }
    
    fileprivate func getImage(forItemAtIndex index: Int) {
        let network = Network.sharedInstance
        guard let thumbnailUrl =  URL(string: self.photos[index].rawUrl + "&" + self.thumbnailParams!)
            else { fatalError() }
        network.downloadPhoto(thumbnailUrl) { (data, success) in
            // Perform UI changes only on main thread.
            if success {
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
//                        print(thumbnailUrl)
                        self.photos[index].thumbnailUrl = thumbnailUrl
//                        print(self.photos[index].thumbnailUrl!)
                        self.photos[index].image = image
                        // Reload cell with fade animation.
                        let indexPath = IndexPath(row: index, section: 0)
                        if self.photoTableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                            self.photoTableView.reloadRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func cancelGetImage(forItemAtIndex index: Int) {
        let network = Network.sharedInstance
        
        if let thumbnailUrl = self.photos[index].thumbnailUrl {
            network.cancelDownloadingPhoto(thumbnailUrl)
        }
    }
}
