//
//  ImageDTO.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 18/12/23.
//

import Foundation

// MARK: - Photo Model (DTO)
struct Photo: Codable {
    let id: Int
    let width: Int
    let height: Int
    let url: String
    let photographer: String
    let photographerUrl: String
    let photographerId: Int
    let avgColor: String
    let src: PhotoSource
    let liked: Bool
    let alt: String
    
    // Mapping for custom CodingKeys
    private enum CodingKeys: String, CodingKey {
        case id, width, height, url, photographer, src, liked, alt,
             photographerUrl = "photographer_url",
             photographerId = "photographer_id",
             avgColor = "avg_color"
    }
}

// MARK: - Photo Source (DTO)
struct PhotoSource: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}

// MARK: - Image Model DTO
struct ImageModelDTO: Codable {
    let page: Int
    let perPage: Int
    let photos: [Photo]
    let totalResults: Int
    let nextPage: String
    let prevPage: String

    // Mapping for custom CodingKeys
    private enum CodingKeys: String, CodingKey {
        case page, photos,
             perPage = "per_page",
             totalResults = "total_results",
             nextPage = "next_page",
             prevPage = "prev_page"
    }

    // Converts DTO to domain model
    func toDomain() -> [ImageModel] {
        return photos.map { photo in
            let imageID: String = String(photo.id)
            return ImageModel(imageID: imageID,
                              thumbnailImageString: photo.src.tiny,
                              originalImageString: photo.src.original,
                              largeImageString: photo.src.large,
                              mediumImageString: photo.src.medium)
        }
    }
}
