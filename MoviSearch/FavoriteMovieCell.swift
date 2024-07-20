//
//  FavoriteMovieCell.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/20/24.
//

import Foundation
import UIKit
import NukeExtensions

class FavoriteMovieCell: UITableViewCell {
    
    @IBOutlet weak var favoriteMovieImageView: UIImageView!
    @IBOutlet weak var favoriteMovieTitleLabel: UILabel!
    
    func configure(with movie: FavoriteMovie) {
        favoriteMovieTitleLabel.text = movie.title

        let placeholderImage = UIImage(systemName: "photo.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let failureImage = UIImage(systemName: "photo.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)

        if let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            let options = ImageLoadingOptions(
                placeholder: placeholderImage,
                failureImage: failureImage,
                contentModes: .init(
                    success: .scaleAspectFill,
                    failure: .scaleAspectFit,
                    placeholder: .scaleAspectFill
                )
            )
            NukeExtensions.loadImage(with: url, options: options, into: favoriteMovieImageView)
        } else {
            favoriteMovieImageView.image = placeholderImage
        }
    }
}
