//
//  UIImageModel.swift
//  PixDownload
//
//  Created by Pritesh Singhvi on 21/12/23.
//

import UIKit

// MARK: - UIImage Model
class UIImageModel: Identifiable {
    // Unique identifier for each image instance
    var id: UUID {
        return UUID() // Generates a unique ID upon creation
    }
    // Properties for image data and state
    var image: UIImage
    var imageId: String
    var isSelected: Bool = false

    // MARK: - Initialization
    init(image: UIImage, imageId: String) {
        self.image = image
        self.imageId = imageId
    }
}
