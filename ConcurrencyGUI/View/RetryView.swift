//
//  RetryView.swift
//  PixDownload
//
//  Created by Pritesh Singhvi on 20/12/23.
//

import Foundation
import SwiftUI

// MARK: - Retry View
struct RetryView: View {
    // Properties for error message and retry action
    let errorMessage: String
    let retryAction: () -> Void

    // MARK: - View Body
    var body: some View {
        VStack {
            // Error message title
            Text("Failed to Download Images")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.red) // Emphasize error with red color
                .padding(.bottom, 8)
            
            // Detailed error message
            Text(errorMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            // Retry button
            Button(action: {
                retryAction() // Trigger the provided retry action
            }) {
                Text("Retry")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue) // Highlight button with blue color
                    .cornerRadius(10) // Rounded corners for visual appeal
            }
        }
    }
}
