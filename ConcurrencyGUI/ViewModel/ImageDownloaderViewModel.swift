//
//  ImageDownloaderViewModel.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 20/12/23.
//

import Foundation
import Combine
import UIKit

// MARK: - ImageViewModel
class ImageDownloaderViewModel: ObservableObject {
    // MARK: - Image status enum
    enum ImageStatus {
        // Describes the possible states of an image fetching process
        case notStarted, inProgress, failed, completed
    }

    // MARK: - Properties
    // Network manager for fetching images
    private let networkManager: ImageAPIServiceProtocol
    // Published array of image model objects with UI-specific properties
    @Published var images: [UIImageModel] = []
    // Published array of image model objects from the API
    @Published var imageModel: [ImageModel] = []
    // Published image fetching status
    @Published var imageStatus: ImageStatus = ImageStatus.notStarted
    // Flag indicating if any image is selected
    var anyImageSelected: Bool {
        (images.filter { $0.isSelected == true }).count > 0
    }
    // Placeholder image for use before actual images are loaded
    private let placeholderImage: UIImage? = UIImage(systemName: "photo.artframe")
    // DispatchQueue for concurrent image downloads
    let queue = DispatchQueue(label: "Images Download",
                              attributes: .concurrent)

    // MARK: - Initialization
    init(networkManager: ImageAPIServiceProtocol = ImageAPIServiceImpl()) {
        self.networkManager = networkManager
    }

    // MARK: - Image fetching
    func fetchImagesData(for searchQuery: String) {
        // Update image status to inProgress
        imageStatus = .inProgress
        // Reset previous data
        resetData()

        // Fetch images from the network manager
        networkManager.fetchImages(for: getImageQuery(for: searchQuery))
            .receive(on: DispatchQueue.main) // Receive results on the main queue
            .subscribe(Subscribers.Sink(receiveCompletion: { [weak self] result in
                switch result {
                    case .finished:
                        break // No specific action needed on completion
                    case .failure(let failure):
                        debugPrint(failure.localizedDescription)
                        self?.imageStatus = .failed // Update status to failed on error
                }
            }, receiveValue: { [weak self] images in
                debugPrint("Images received")
                self?.imageModel = images // Update image model with received data
                self?.fetchImages() // Initiate image fetching process
            }))
    }

    // MARK: - Image Fetching
    func fetchImages() {
        // Iterate through each image in the image model array
        for image in imageModel {
            // Asynchronously fetch individual images
            queue.async { [weak self] in
                guard let self else { return }

                // Fetch the image data from the network manager
                self.networkManager.fetchImages(for: image.largeImageString)
                    .receive(on: DispatchQueue.main) // Receive results on the main queue
                    .subscribe(Subscribers.Sink(receiveCompletion: { result in
                        switch result {
                            case .finished:
                                break // No specific action needed on completion
                            case .failure(let failure):
                                debugPrint(failure.localizedDescription)
                        }
                    }, receiveValue: { imageData in
                        // Attempt to create a UIImage from the received data
                        guard let uiImage = UIImage(data: imageData) else {
                            debugPrint("Data Image Parsing Failed")
                            self.addImageToArray(self.placeholderImage, image) // Use placeholder if parsing fails
                            return
                        }
                        // Add the successfully parsed UIImage to the array
                        self.addImageToArray(uiImage, image)
                    }))
            }
        }
    }

    // MARK: - Query Construction
    func getImageQuery(for query: String) -> [URLQueryItem] {
        // Create query items for image search
        let queryItem: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(10)), // Number of images per page
            URLQueryItem(name: "page", value: String(Int.random(in: 1...5))) // Random page for variety
        ]
        return queryItem
    }

    // MARK: - Image Array Management
    private func addImageToArray(_ image: UIImage?,
                                 _ imageDataModel: ImageModel) {
        guard let image else { return } // Ensure image is not nil
        
        // Create a UIImageModel for UI-specific representation
        let imageModel = UIImageModel(image: image,
                                      imageId: imageDataModel.imageID)
        // Synchronize access to the images array using a barrier
        queue.sync(flags: .barrier) { [weak self] in
            guard let self else { return }
            
            // Append the image model to the array
            self.images.append(imageModel)
            
            // Update image status to completed if images are available
            if imageStatus != .completed {
                self.imageStatus = self.images.count > 0 ? .completed : self.imageStatus
            }
        }
    }
    // MARK: - Data Reset
    private func resetData() {
        // Clear existing image data to prepare for new results
        imageModel.removeAll()
        images.removeAll()
    }
}

extension ImageDownloaderViewModel {
    // MARK: - Image Selection Management
    func updateAllImageSelectionStatus(to selectionStatus: Bool) {
        // Iterate through each image in the images array
        images.forEach { updateImageSelectionStatus($0,
                                                    selectionStatus: selectionStatus)}
    }

    func updateImageSelectionStatus(_ imageModel: UIImageModel,
                                    selectionStatus: Bool? = nil) {
        // Set the image's selected status based on the provided value or toggle it
        if let selectionStatus {
            imageModel.isSelected = selectionStatus
        } else {
            imageModel.isSelected.toggle() // Invert the current selection state
        }
        // Find the index of the image in the images array
        if let imageToUpdateIndex = images.firstIndex(where: {
            $0.imageId == imageModel.imageId
        }) {
            // Update the image model in the array with the new selection status
            images[imageToUpdateIndex] = imageModel
        }
    }
}
