//
//  PhotoTableView.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

// based on https://stackoverflow.com/a/45157417
extension UITableView {

    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        messageLabel.sizeToFit()

        DispatchQueue.main.async {
            self.backgroundView = messageLabel
        }
    }
    
    func displayLoadingIndicator() {
        let loadingIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        loadingIndicatorView.sizeToFit()
        let spinner = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.large)
        spinner.startAnimating()
        spinner.center = loadingIndicatorView.center
        loadingIndicatorView.addSubview(spinner)
        
        DispatchQueue.main.async {
            self.backgroundView = loadingIndicatorView
        }
    }

    func restore() {
        DispatchQueue.main.async {
            self.backgroundView = nil
        }
    }
}

class PhotoTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorStyle = .none
    }
    
    

}
