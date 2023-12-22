//
//  ViewController.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 18/12/23.
//

import UIKit
import Photos
import Combine
import SwiftUI


class ViewController: UIViewController {
    // MARK: - Properties
    // Manages interaction with the device's photo library
    private var libraryManager: PhotosLibraryManager?

    // Handles image fetching (implementation not shown)
    private let imageDownloaderViewModel = ImageDownloaderViewModel()

    // Custom view representing the main UI
    private var pixDownloadMainView = PixDownloadMainView()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up view bindings for button actions
        setupViewBindings()
        
        // Initialize the photo library manager
        setupPhotoLibraryManager()
        
        // Add the main UI view to the screen
        addSubSwiftUIView(pixDownloadMainView, to: self.view)
    }

    // MARK: - View Binding
    func setupViewBindings() {
        // Bind a closure to the saveToPhotosButtonTapped event of pixDownloadMainView
        pixDownloadMainView.saveToPhotosButtonTapped = { [weak self] images in
            debugPrint("Save to photos tapped")
            // Filter selected images based on their isSelected property
            let selectedImages = images.filter{ $0.isSelected == true }

            // Proceed to save if images are selected, otherwise show an alert
            if selectedImages.count > 0 {
                self?.saveImagesToPhotosForImages(selectedImages)
            } else {
                self?.showAlertWith(title: "No image selected",
                                    message: "Select atleast one image to save")
            }
        }
    }

    // MARK: - Photo Library Management
    func setupPhotoLibraryManager() {
        // Ensure libraryManager is created only once
        if libraryManager == nil {
            libraryManager = PhotosLibraryManager()
            // Set up a closure for the library manager to display alerts
            libraryManager?.showAlertMessage = { [weak self] title, message in
                self?.showAlertWith(title: title, message: message)
            }
        }
    }
    
    // MARK: - Image Saving
    func saveImagesToPhotosForImages(_ images: [UIImageModel]) {
        // Delegate the saving process to the library manager
        libraryManager?.savePhotos(for: images, photoSavedCallBack: { [weak self] save, unsave in
            // Handle the saving completion and display appropriate alerts
            self?.showAlertForPhotoSaved(saveCount: save, unsaveCount: unsave)
        })
    }

    // MARK: - Alert Handling
    func showAlertForPhotoSaved(saveCount: Int, unsaveCount: Int) {
        // Construct informative alert messages based on saving results
        var title = ""
        var message = ""

        if saveCount == 0 && unsaveCount == 0 {
            title = "No Photos Saved"
        } else if saveCount > 0 && unsaveCount == 0 {
            title = "Photos Saved Successfully"
            message = "\(saveCount) photos saved"
        } else if saveCount == 0 && unsaveCount > 0 {
            title = "Failed to Save Photos"
            message =  "\(unsaveCount) photo unsaved"
        } else if saveCount > 0 && unsaveCount > 0 {
            title = "Some Photos Failed to Saved"
            message = "\(saveCount) photos saved & \(unsaveCount) photo unsaved"
        }
        
        // Display the constructed alert
        showAlertWith(title: title, message: message)
    }
}
