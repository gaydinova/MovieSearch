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

        if let posterPath = movie.posterPath {
            ImageLoader.shared.loadImage(with: posterPath, into: favoriteMovieImageView)
        }
    }
}
