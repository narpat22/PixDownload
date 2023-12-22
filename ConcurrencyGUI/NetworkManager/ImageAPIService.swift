//
//  ImageAPIService.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 18/12/23.
//

import Foundation
import Combine

// MARK: - Image API Error Handling
enum ImageAPIError: Error {
    // Generic error for underlying request failures
    case requestFailed(Error)
    case invalidURL // Invalid URL encountered
    case invalidResponse // Server responded with an error status code
    case dataParsingError  // Failed to parse the received data
}

// MARK: - Image API Service Protocol
protocol ImageAPIServiceProtocol {
    func fetchImages(for queryParameters: [URLQueryItem]) -> AnyPublisher<[ImageModel], ImageAPIError>
    func fetchImages(for image: String) -> AnyPublisher<Data, ImageAPIError>
}

// MARK: - Image API Service Implementation
class ImageAPIServiceImpl: ImageAPIServiceProtocol {
    // MARK: - Constants
    private struct Constants {
        let urlString: String = "https://api.pexels.com/v1/search"
    }
    private let constants = Constants()
    
    // MARK: - Fetch Images (Search Query)
    func fetchImages(for queryParameters: [URLQueryItem]) -> AnyPublisher<[ImageModel], ImageAPIError> {
        // Construct the URL with query parameters
        guard var url = URL(string: constants.urlString) else {
            return Fail(error: ImageAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        url.append(queryItems: queryParameters)

        // Create the request with API key authentication
        var request = URLRequest(url: url)
        request.addValue(APIKey.apiKey, forHTTPHeaderField: "Authorization")

        // Perform the network request and handle results
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // Log the response URL for debugging
                debugPrint(response.url?.absoluteString ?? "")
                
                // Validate the HTTP response status code
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw ImageAPIError.invalidResponse
                }
                
                // Decode the JSON data into ImageModelDTO/
                let imageModelDTO = try JSONDecoder().decode(ImageModelDTO.self, from: data)
                
                // Convert DTO to domain model
                let imageModel = imageModelDTO.toDomain()
                return imageModel
            }
            .mapError { ImageAPIError.requestFailed($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - Fetch Images (Direct Image URL)
    func fetchImages(for image: String) -> AnyPublisher<Data, ImageAPIError> {
        // Validate the image URL
        guard let url = URL(string: image) else {
            return Fail(error: ImageAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        // Perform the network request and handle results (data only)
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // Extract the raw image data
            .mapError { ImageAPIError.requestFailed($0) }
            .eraseToAnyPublisher()
    }
}
