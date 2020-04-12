//
//  TestTableViewController.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class PhotoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var photoTableView : PhotoTableView!
    
    var photos : [Photo] = []
    let cellReuseIdentifier = "photoCellViewReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // instantiate the table
        photoTableView = UINib(nibName: "PhotoTableView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PhotoTableView
        
        // set table delegate and data source
        photoTableView.dataSource = self
        photoTableView.delegate = self
        
        for n in 1...40 {
            photos.append(Photo(photoUrl: "test \(n)"))
        }
        
        // Register table view cell
        photoTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        self.title = "Photos"
        self.view = photoTableView
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCellView = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)

        let photo = photos[indexPath.row]
        photoCellView.textLabel?.text = photo.photoUrl

        return photoCellView
    }

}
