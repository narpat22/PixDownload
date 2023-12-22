//
//  ImageModel.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 18/12/23.
//

import Foundation

// MARK: - Image Model
struct ImageModel: Identifiable {
    // Unique identifier for each image instance
    var id: UUID {
        return UUID() // Generates a unique ID upon creation
    }
    // Properties for image URLs
    var imageID: String
    var thumbnailImageString: String
    var originalImageString: String
    var largeImageString: String
    var mediumImageString: String
}
