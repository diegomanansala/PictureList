//
//  PhotoDetailsView.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 15/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

protocol PhotoDetailsViewDelegate
{
    func didPressCloseButton()
}

extension PhotoDetailsViewDelegate {
    
    func didPressCloseButton() {}
}


class PhotoDetailsView: UIView {
    
    var delegate:PhotoDetailsViewDelegate?

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    
    @IBAction func pressedCloseButton(_ sender: Any) {
        delegate?.didPressCloseButton()
    }
    

}
