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
    let loadingCellReuseIdentifier = "loadingCellViewReuseIdentifier"
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
        
        // Register Loading Cell
        let loadingTableViewCellNib = UINib(nibName: "LoadingTableViewCell", bundle: nil)
        photoTableView.register(loadingTableViewCellNib, forCellReuseIdentifier: loadingCellReuseIdentifier)
        
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
                    if results.count > 0 {
                        self.page = self.page + 1
                        DispatchQueue.global().async {
                            self.photos += results
                            DispatchQueue.main.async {
                                self.photoTableView.reloadData()
                                self.isLoadingMore = false
                            }
                        }
                    } else if results.count == 0 && self.isAtBottom(self.photoTableView) {
                        DispatchQueue.global().async {
                            DispatchQueue.main.async {
                                // calculate Y of last cell before the loading cell
                                let scrollToY = self.photoTableView.contentSize.height - self.photoTableView.frame.size.height - 55.0
                                // scroll up to last cell before the loading cell to avoid continually calling loadMoreData
                                self.photoTableView.setContentOffset(CGPoint(x: 0.0, y: scrollToY), animated: true)
                            }
                        }
                    }
                }
            }
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
        if indexPath.section == 0 {
            return imageHeight
        } else {
            return CGFloat(55.0) // Loading cell height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return imageHeight
        } else {
            return CGFloat(55.0) // Loading cell height
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // Do not display the load more cell when there are no records to show
        if photos.count > 0 {
            return 2
        }
        
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
            
            if section == 1 {
                // For the loading cell
                return 1
            }
        }
        
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
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
        
        let loadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: loadingCellReuseIdentifier, for: indexPath) as! LoadingTableViewCell
        loadingTableViewCell.activityIndicator.startAnimating()
        return loadingTableViewCell
        
    }
    
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        print("prefetchRowsAt \(indexPaths)")
        indexPaths.forEach { (idxPath) in
            if idxPath.section == 0 {
                self.getImage(forItemAtIndex: idxPath.row)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        print("cancelPrefetchingForRowsAt \(indexPaths)")
        indexPaths.forEach { (idxPath) in
            if idxPath.section == 0 {
                self.cancelGetImage(forItemAtIndex: idxPath.row)
            }
        }
    }
    
    fileprivate func getImage(forItemAtIndex index: Int) {
        let network = Network.sharedInstance
        guard let thumbnailUrl =  URL(string: self.photos[index].rawUrl + "&" + self.thumbnailParams!)
            else { fatalError() }
        
        network.downloadPhoto(thumbnailUrl, imageId: self.photos[index].id) { (data, success) in
            // Perform UI changes only on main thread.
            if success {
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self.photos[index].thumbnailUrl = thumbnailUrl
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
        
        if let _ = self.photos[index].thumbnailUrl {
            network.cancelDownloadingPhoto(imageId: self.photos[index].id)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if photos.count > 0 {
            // Run loadMoreData only when user scrolls to the bottom
            // and there is no load more request currently running
            if self.isAtBottom(scrollView) && !self.isLoadingMore {
                self.loadMoreData()
            }
        }
    }
    
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // this delegate will only be called when the table view animates up after a load more call returns empty
        self.isLoadingMore = false
    }
    
    func isAtBottom(_ scrollView: UIScrollView) -> Bool {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset - 55.0
        
        return distanceFromBottom < height
    }
}
