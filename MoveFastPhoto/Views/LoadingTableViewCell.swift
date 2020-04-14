//
//  LoadingTableViewCell.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 14/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

// based on https://johncodeos.com/how-to-add-load-more-infinite-scrolling-in-ios-using-swift/
class LoadingTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
