//
//  PixDownloadMainView.swift
//  ConcurrencyGUI
//
//  Created by Pritesh Singhvi on 18/12/23.
//

import SwiftUI

// MARK: - Main View Structure
struct PixDownloadMainView: View {
    // ObservedObject for image data and state
    @ObservedObject var imageDownloaderViewModel = ImageDownloaderViewModel()
    // State variables for search text, selection states, and error message
    @State var searchedText: String = ""
    @State var isSelected: Bool = false // Toggles image selection mode
    @State var isSelectAll: Bool = false // Toggles selection of all images
    private var errorMessage = "There was an error downloading images. Please check your internet connection and try again."
    
    // Callback for saving images to photos
    var saveToPhotosButtonTapped: (([UIImageModel]) -> Void)?
    
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            imageView
                .navigationTitle("PixDownload")
                .scrollDismissesKeyboard(.immediately)
                .toolbar {
                    // TopBarTrailing: Select/Cancel button
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(!isSelected ? "Select" : "Cancel") {
                            if isSelected {
                                imageDownloaderViewModel.updateAllImageSelectionStatus(to: false)
                            }
                            isSelected.toggle()
                        }
                    }
                    // TopBarLeading: Select All/Deselect All button (only in selection mode)
                    if isSelected {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(isSelectAll ? "Deselect All" : "Select All") {
                                imageDownloaderViewModel
                                    .updateAllImageSelectionStatus(to: !isSelectAll)
                                isSelectAll.toggle()
                            }
                        }
                        // BottomBar: Save To Photos button (only in selection mode)
                        ToolbarItem(placement: .bottomBar) {
                            Button("Save To Photos") {
                                print("select all tapped")
                                // Calls the provided callback to trigger saving
                                saveToPhotosButtonTapped?(imageDownloaderViewModel.images)
                            }
                            .disabled(!(imageDownloaderViewModel.anyImageSelected))
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchedText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Images...")
        .onAppear {
            // Fetch initial images on view appearance
            imageDownloaderViewModel.fetchImagesData(for: "nature")
        }
        .onSubmit(of: .search) {
            // Fetch images based on search query
            imageDownloaderViewModel.fetchImagesData(for: searchedText)
        }
    }
    
    @ViewBuilder var imageView: some View {
        // Dynamically display content based on image loading status
        switch imageDownloaderViewModel.imageStatus {
            case .notStarted, .inProgress:
                ProgressView() // Show progress indicator
            case .failed:
                RetryView(errorMessage: errorMessage) {
                    // Retry fetching images on tap
                    imageDownloaderViewModel.fetchImagesData(for: searchedText)
                }
            case .completed:
                let _ = debugPrint("Completed Fired")
                ImageCardView(images: imageDownloaderViewModel.images, canSelectImage: isSelected) { model in
                    // Update image selection state on tap
                    imageDownloaderViewModel.updateImageSelectionStatus(model)
                }
        }
    }
}
