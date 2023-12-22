//
//  PhotosLibraryManager.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 18/12/23.
//

import UIKit
import Photos

typealias AlertMessageBlock = ((String, String?) -> Void)
class PhotosLibraryManager {
    // Optional block for displaying alert messages
    var showAlertMessage: AlertMessageBlock?

    // Private properties
    private var isAuthroized: Bool {
        // Check for authorization status to access photo library
        return PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized
    }
    private let concurrentQueue = DispatchQueue(label: "com.concurrentQueue",
                                        attributes: .concurrent)
    private let dispatchGroup = DispatchGroup()

    // Initializer
    init() {
        // Request authorization immediately upon object creation
        requestAuthorization()
    }

    // Function for requesting authorization to access the photo library
    func requestAuthorization() {
        guard !isAuthroized else { return }
        // Request authorization if not already granted
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            debugPrint("requested")
            switch status {
                case .authorized:
                    debugPrint("Thank you for authroization")
                default:
                    debugPrint("Authorization Denined")
                    self?.showAlertMessage?("Authorization Denined", "Please give premission from settings")
            }
        }
    }

    // Function for saving photos to the library
    func savePhotos(for images: [UIImageModel],
                    photoSavedCallBack: @escaping ((Int, Int) -> Void)) {
        guard isAuthroized else {
            // Handle authorization denial
            showAlertMessage?("Authorization Denined", "Please give premission from settings")
            return
        }
        var saveCount: Int = 0
        var unsaveCount: Int = 0

        // Enter dispatch group to track asynchronous tasks
        dispatchGroup.enter()

        // Iterate through images and save them concurrently
        for image in images {
            concurrentQueue.async {
                // Perform changes to the photo library
                PHPhotoLibrary.shared().performChanges {
                    PHAssetCreationRequest.creationRequestForAsset(from: image.image)
                } completionHandler: { [weak self] success, error in
                    if success {
                        debugPrint("Photo Saved Successfully")
                        saveCount += 1
                    } else if let error {
                        debugPrint("Error while saving image with error \(error.localizedDescription)")
                        unsaveCount += 1
                    }
                    // Leave dispatch group when all images are processed
                    if saveCount + unsaveCount == images.count {
                        self?.dispatchGroup.leave()
                    }
                }
            }
        }
        // Notify on the main queue after all tasks complete
        dispatchGroup.notify(queue: .main) {
            // Call the callback with the final counts of saved and unsaved images
            photoSavedCallBack(saveCount, unsaveCount)
        }
    }
}
