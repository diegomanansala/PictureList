//
//  PhotoDetailsViewController.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 15/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController, PhotoDetailsViewDelegate {

    var photoDetailsView : PhotoDetailsView!
    var photoId : String?
    var photoRawUrl : String?
    var photoDescription : String?
    var photoLikes : Int?
    var photoWidth : Int?
    var photoHeight : Int?
    var bgColor: String?
    
    var metaDataIsHidden = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        photoDetailsView = UINib(nibName: "PhotoDetailsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? PhotoDetailsView
        photoDetailsView.delegate = self
        self.view = photoDetailsView
        
        photoDetailsView.activityIndicator.startAnimating()

        if var backgroundColor = self.bgColor {
            DispatchQueue.global().async {
                backgroundColor.remove(at: backgroundColor.startIndex)
                var rgbValue:UInt64 = 0
                Scanner(string: backgroundColor).scanHexInt64(&rgbValue)
                DispatchQueue.main.async {
                    let redColor = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
                    let greenColor = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
                    let blueColor = CGFloat(rgbValue & 0x0000FF) / 255.0
                    
                    self.photoDetailsView.backgroundColor = UIColor(
                        red: redColor,
                        green: greenColor,
                        blue: blueColor,
                        alpha: CGFloat(1.0)
                    )
                    
                    // based on https://stackoverflow.com/a/3943023
                    // determine color of close button
                    let L = 0.2126 * redColor + 0.7152 * greenColor + 0.0722 * blueColor
                    self.photoDetailsView.closeButton.setTitleColor(L > 0.179 ? UIColor.black : UIColor.white, for: .normal)
                    self.photoDetailsView.activityIndicator.color = L > 0.179 ? .secondarySystemFill : .secondaryLabel
                }
            }
        }
        
        let imageWidth = photoDetailsView.imageContainerView.frame.size.width
        let imageHeight = photoDetailsView.imageContainerView.frame.size.width
        let imageParams = ["q": "80", // compression quality when using lossy file formats
         "fm": "png", // image format
         "crop": "entropy", // crop mode
         "cs": "tinysrgb",
         "dpr": "2", // device pixel ratio
         "w": "\(Int(imageWidth))", // width
         "h": "\(Int(imageHeight))"] // height
        .map({ (k,v) in "\(k)=\(v)"  }).joined(separator: "&")
        
        if let url = photoRawUrl {
            // load image
            guard let photoUrl =  URL(string: url + "&" + imageParams)
                else { fatalError() }
            let network = Network.sharedInstance
            
            network.downloadPhoto(photoUrl) { (data, success) in
                // Perform UI changes only on main thread.
                if success {
                    DispatchQueue.main.async {
                        if let data = data,
                        let image = UIImage(data: data),
                        let imageView = self.photoDetailsView.photo {
                            self.photoDetailsView.activityIndicator.stopAnimating()
                            imageView.alpha = 0
                            imageView.image = image
                            
                            UIView.animate(withDuration: 0.6) {
                                imageView.alpha = 1
                            }
                        }
                    }
                }
            }
        }
        
        var metaDataText = ""
        
        if let photoDescription = self.photoDescription {
            metaDataText += "\(photoDescription)\n\n"
        }
        
        if let photoLikes = self.photoLikes {
            metaDataText += "Likes: \(photoLikes)\n"
        }
        
        if let photoWidth = self.photoWidth,
        let photoHeight = self.photoHeight {
            metaDataText += "Dimensions: \(photoWidth) x \(photoHeight)\n"
        }
        
        if metaDataText.count > 0 {
            photoDetailsView.imageMetaData.text = metaDataText
            
            
            photoDetailsView.imageMetaData.numberOfLines = 0
            photoDetailsView.imageMetaData.sizeToFit()
            photoDetailsView.imageMetaData.layoutIfNeeded()
            
            // add tap gesture to image
            if let imageView = photoDetailsView.photo {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(tapGestureRecognizer)
            }
        }
        
        self.metaDataIsHidden = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        self.photoDetailsView.imageMetaDataContainer.alpha = 1
        self.photoDetailsView.closeButton.alpha = 1
        
        if let imageView = self.photoDetailsView.photo {
            imageView.image = nil
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        // Your action
        self.metaDataIsHidden = !self.metaDataIsHidden
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.photoDetailsView.imageMetaDataContainer.alpha = self.metaDataIsHidden ? 0 : 1
                self.photoDetailsView.closeButton.alpha = self.metaDataIsHidden ? 0 : 1
            }
        }
        
    }
    
    func didPressCloseButton() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
