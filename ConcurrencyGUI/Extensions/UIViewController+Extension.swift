//
//  UIViewController+Extension.swift
//  PixDownload
//
//  Created by Pritesh Singhvi on 21/12/23.
//

import UIKit
import SwiftUI

extension UIViewController {
    // Function to display an alert with the given title and message
    func showAlertWith(title: String, message: String?) {
        // Create an alert controller with the specified title and message
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Add an "OK" action to dismiss the alert
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        // Ensure presentation on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            // Present the alert controller, handling potential self-referencing issues
            self?.present(alertController, animated: true)
        }
    }

    func addSubSwiftUIView<Content>(_ swiftUIView: Content,
                                    to view: UIView) where Content: View {
        let hostingController = UIHostingController(rootView: swiftUIView)
        // Add as a child of the current view controller.
        addChild(hostingController)
        // Add the SwiftUI view to the view controller view hierarchy.
        view.addSubview(hostingController.view)
        // Setup the contraints to update the SwiftUI view boundaries.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            view.bottomAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            view.rightAnchor.constraint(equalTo: hostingController.view.rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        // Notify the hosting controller that it has been moved to the current view controller.
        hostingController.didMove(toParent: self)
    }
}

