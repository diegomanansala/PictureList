//
//  Photo.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import UIKit

struct Photo {
    let id: String
    let imageDescription: String?
    let likes: Int
    let width: Int
    let height: Int
    let color: String
    let selfLink: String
    let rawUrl: String
    var image: UIImage?
    var thumbnailUrl: URL?
}

extension Photo {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let likes = json["likes"] as? Int,
            let width = json["width"] as? Int,
            let height = json["height"] as? Int,
            let color = json["color"] as? String,
            let links = json["links"] as? [String: String],
            let selfLink = links["self"],
            let urls = json["urls"] as? [String: String],
            let rawUrl = urls["raw"]
        else {
            return nil
        }

        self.id = id
        self.imageDescription = json["description"] as? String
        self.likes = likes
        self.width = width
        self.height = height
        self.color = color
        self.selfLink = selfLink
        self.rawUrl = rawUrl
    }
}
