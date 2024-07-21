//
//  MovieDetailViewController.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/4/24.
//

import Foundation
import UIKit
import CoreData
import NukeExtensions

class MovieDetailsViewController: UIViewController, AlertPresentable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var movieGenre: UILabel!
    @IBOutlet weak var movieDuration: UILabel!
    @IBOutlet weak var writers: UILabel!
    @IBOutlet weak var directors: UILabel!
    @IBOutlet weak var directorName: UILabel!
    @IBOutlet weak var writerName: UILabel!
    @IBOutlet weak var cast: UILabel!
    @IBOutlet weak var castName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext?
    var movieDetails: MovieDetails?
    let movieService = MovieService()
    var isFromFavorites: Bool = false
    
    // This property updates the favorite icon when its value changes
    var isFavorite: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.favoriteIcon.image = self.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            }
        }
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let movie = movieDetails {
            updateUI(with: movie)
        } else {
            showErrorAlert(message: "Movie details are not available.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIfFavorite()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        setupFavoriteIconGesture()
        styleUI()
        addDescriptionDivider()
    }
    
    private func setupFavoriteIconGesture() {
        let favoriteTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFavorite))
        favoriteIcon.addGestureRecognizer(favoriteTapGesture)
        favoriteIcon.isUserInteractionEnabled = true
    }
    
    private func styleUI() {
        movieName.applyTitleStyle()
        movieYear.applySubtitleStyle()
        movieGenre.applySubtitleStyle()
        movieDuration.applySubtitleStyle()
        castName.applyBodyStyle()
        writerName.applyBodyStyle()
        directorName.applyBodyStyle()
        cast.applySectionTitleStyle()
        writers.applySectionTitleStyle()
        directors.applySectionTitleStyle()
        descriptionLabel.applySectionTitleStyle()
        descriptionText.applyDescriptionStyle()
        favoriteIcon.applyFavoriteIconStyle()
        moviePoster.layer.cornerRadius = 10
        moviePoster.clipsToBounds = true
    }

    
    func addDescriptionDivider() {
        // Adding a divider line above the description label
        let dividerColor = UIColor.lightGray
        let divider = createDivider(color: dividerColor)
        view.addSubview(divider)
        
        // Constraints for the divider
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func createDivider(color: UIColor) -> UIView {
        let divider = UIView()
        divider.backgroundColor = color
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }
    
    // MARK: - UI Update Methods
    
    func updateUI(with movie: MovieDetails) {
        // Hide the favorite icon if the view controller is accessed from the favorites list
        favoriteIcon.isHidden = isFromFavorites
        self.movieName.text = movie.title
        self.descriptionText.text = movie.overview
        self.movieYear.text = movie.releaseDate
        self.movieGenre.text = movie.genres.map { $0.name }.joined(separator: ", ")
        self.movieDuration.text = "\(movie.runtime ?? 0) min"
        self.writerName.text = movie.credits?.crew.filter { $0.job == "Writer" }.map { $0.name }.joined(separator: ", ")
        self.directorName.text = movie.credits?.crew.filter { $0.job == "Director" }.map { $0.name }.joined(separator: ", ")
        
        // Display a limited number of cast members
        if let castMembers = movie.credits?.cast.prefix(7) {
            self.castName.text = castMembers.map { $0.name }.joined(separator: ", ")
        }
       
        // Load the movie poster image
        if let posterPath = movie.posterPath {
            ImageLoader.shared.loadImage(with: posterPath, into: moviePoster)
        }
    }
    
    func updateFavoriteIcon() {
        DispatchQueue.main.async {
            self.favoriteIcon.image = self.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
    }
    
    // MARK: - Favorite Handling Methods
   
    // Toggle the favorite status of the movie
    @objc func toggleFavorite() {
        guard let context = managedObjectContext, let movieId = movieDetails?.id else {
            showErrorAlert(message: "Managed object context or movie ID not available")
            return
        }
        
        isFavorite.toggle()
        updateFavoriteIcon()
        
        // Perform the favorite status update in the background
        DispatchQueue.global(qos: .background).async {
            do {
                // Add the movie to favorites
                if self.isFavorite {
                    let favoritedMovie = FavoriteMovie(context: context)
                    favoritedMovie.id = Int64(movieId)
                    favoritedMovie.title = self.movieDetails?.title
                    favoritedMovie.posterPath = self.movieDetails?.posterPath
                } else {
                    // Remove the movie from favorites
                    let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
                    
                    let results = try context.fetch(fetchRequest)
                    if let movieToDelete = results.first {
                        context.delete(movieToDelete)
                    }
                }
                try context.save()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .didUpdateFavorites, object: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Failed to update favorite status: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkIfFavorite() {
        guard let context = managedObjectContext, let movieId = movieDetails?.id else { return }
        
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movieId)
        
        do {
            let results = try context.fetch(fetchRequest)
            isFavorite = !results.isEmpty
        } catch {
            showErrorAlert(message: "Failed to fetch favorite status: \(error.localizedDescription)")
        }
    }
}

