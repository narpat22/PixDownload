//
//  ImageCardView.swift
//  PixDownload
//
//  Created by Pritesh Singhvi on 20/12/23.
//

import SwiftUI

// MARK: - Image Card View
struct ImageCardView: View {
    // Properties
    var images: [UIImageModel] = []
    var canSelectImage: Bool
    var updateImageSelectionStatus: (UIImageModel) -> Void

    // MARK: - View Body
    var body: some View {
        ScrollView {
            VStack {
                ForEach(images) { image in
                    ZStack(alignment: .bottomTrailing) {
                        // Base card view
                        cardView(image: image.image)
                            .overlay {
                                // Overlay for selected images
                                if image.isSelected {
                                    Rectangle()
                                        .foregroundStyle(.windowBackground)
                                        .opacity(0.3) // Semi-transparent overlay
                                }
                            }
                        // Checkmark for selected images
                        if image.isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                                .background(in: .circle) // Circular background
                                .offset(x: -16, y: -20) // Position adjustment
                        }
                    }
                    .padding(.bottom, 8)
                    .onTapGesture {
                        // Handle tap gesture for image selection
                        if canSelectImage {
                            updateImageSelectionStatus(image) // Update selection state
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Card View
    @ViewBuilder func cardView(image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit) // Maintain image aspect ratio
                .cornerRadius(10)  // Rounded corners
        }
        .background(Color.white)
        .cornerRadius(15) // Rounded corners for the card
        .shadow(radius: 5)  // Add a subtle shadow effect
    }
}
