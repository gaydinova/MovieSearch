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
    static let shared = ImageLoader()
    private init() {}
    
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"

    @MainActor 
    func loadImage(with path: String, into imageView: UIImageView) {
        let placeholderImage = UIImage(systemName: "photo.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let failureImage = UIImage(systemName: "photo.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        
        guard let url = URL(string: "\(imageBaseURL)\(path)") else {
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
        
        NukeExtensions.loadImage(with: url, options: options, into: imageView)
    }
}
