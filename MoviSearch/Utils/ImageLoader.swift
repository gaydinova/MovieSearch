//
//  ImageLoader.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/20/24.
//

import Foundation
import NukeExtensions
import UIKit

class ImageLoader {
    // Singleton instance of ImageLoader
    static let shared = ImageLoader()
    private init() {}
    
    // Base URL for loading images from the TMDB API
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"

    @MainActor 
    func loadImage(with path: String, into imageView: UIImageView) {
        let placeholderImage = UIImage(systemName: "photo.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let failureImage = UIImage(systemName: "photo.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        guard let url = URL(string: "\(imageBaseURL)\(path)") else {
            // If URL construction fails, set the placeholder image
            imageView.image = placeholderImage
            return
        }

        let options = ImageLoadingOptions(
            placeholder: placeholderImage,
            failureImage: failureImage,
            contentModes: .init(
                success: .scaleAspectFill,
                failure: .scaleAspectFit,
                placeholder: .scaleAspectFill
            )
        )
        // Load the image using the Nuke library and the specified options
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
    }
}
