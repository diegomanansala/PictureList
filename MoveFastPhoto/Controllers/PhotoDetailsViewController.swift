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
    var bgColor: String?
    
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

        if var backgroundColor = self.bgColor {
            DispatchQueue.global().async {
                print(backgroundColor)
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
        
        photoDetailsView.activityIndicator.startAnimating()
        if let url = photoRawUrl {
            // load image
            guard let photoUrl =  URL(string: url + "&" + imageParams)
                else { fatalError() }
            let network = Network.sharedInstance
            print(photoUrl)
            
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
//
//        if let photoId = photoId {
//            // load photo details
//        }
        
//        if let comment = cookingRecordImageComment {
//            displayRecordView.cookingRecordCommentLabel.text = comment
//            displayRecordView.cookingRecordCommentLabel.numberOfLines = 0
//            displayRecordView.cookingRecordCommentLabel.sizeToFit()
//            displayRecordView.cookingRecordCommentLabel.layoutIfNeeded()
//        }

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if let imageView = self.photoDetailsView.photo {
            imageView.image = nil
        }
    }
    
    func didPressCloseButton() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
