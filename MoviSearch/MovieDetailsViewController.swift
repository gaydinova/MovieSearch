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
    
    var managedObjectContext: NSManagedObjectContext?
    var movieDetails: MovieDetails?
    let movieService = MovieService()
    var isFromFavorites: Bool = false
 
    override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)

          if let movie = self.movieDetails {
              self.updateUI(with: movie)
          } else {
              showErrorAlert(message: "Movie details are not available.")
          }

          let favoriteTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFavorite))
          favoriteIcon.addGestureRecognizer(favoriteTapGesture)
          favoriteIcon.isUserInteractionEnabled = true

          styleUI()
          addDescriptionDivider()
      }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          checkIfFavorite()
      }
    
    var isFavorite: Bool = false {
          didSet {
              DispatchQueue.main.async {
                  self.favoriteIcon.image = self.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
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
    
    func updateFavoriteIcon() {
           DispatchQueue.main.async {
               self.favoriteIcon.image = self.isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
           }
       }
    
    @objc func toggleFavorite() {
         guard let context = managedObjectContext, let movieId = movieDetails?.id else {
             showErrorAlert(message: "Managed object context or movie ID not available")
             return
         }
         
         isFavorite.toggle()
         updateFavoriteIcon()

         DispatchQueue.global(qos: .background).async {
             do {
                 if self.isFavorite {
                     let favoritedMovie = FavoriteMovie(context: context)
                     favoritedMovie.id = Int64(movieId)
                     favoritedMovie.title = self.movieDetails?.title
                     favoritedMovie.posterPath = self.movieDetails?.posterPath
                 } else {
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
    
    func updateUI(with movie: MovieDetails) {
        favoriteIcon.isHidden = isFromFavorites
        self.movieName.text = movie.title
        self.descriptionText.text = movie.overview
        self.movieYear.text = movie.releaseDate
        self.movieGenre.text = movie.genres.map { $0.name }.joined(separator: ", ")
        self.movieDuration.text = "\(movie.runtime ?? 0) min"
        self.writerName.text = movie.credits?.crew.filter { $0.job == "Writer" }.map { $0.name }.joined(separator: ", ")
        self.directorName.text = movie.credits?.crew.filter { $0.job == "Director" }.map { $0.name }.joined(separator: ", ")
        if let castMembers = movie.credits?.cast.prefix(7) {
            self.castName.text = castMembers.map { $0.name }.joined(separator: ", ")
        }
        
        if let posterPath = movie.posterPath {
            ImageLoader.shared.loadImage(with: posterPath, into: moviePoster)
        }
    }
    
    func styleUI() {
        // Title styling
        movieName.font = UIFont.boldSystemFont(ofSize: 24)
        movieName.textColor = UIColor.white
        movieName.numberOfLines = 0
        
        movieName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        movieName.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // Year, duration, genre styling
        let smallFont = UIFont.italicSystemFont(ofSize: 14)
        movieYear.font = smallFont
        movieGenre.font = smallFont
        movieDuration.font = smallFont
        movieYear.textColor = UIColor.lightGray
        movieGenre.textColor = UIColor.lightGray
        movieDuration.textColor = UIColor.lightGray
        
        // Cast, writers, directors names styling
        let nameFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        castName.font = nameFont
        writerName.font = nameFont
        directorName.font = nameFont
        castName.textColor = UIColor.lightGray
        writerName.textColor = UIColor.lightGray
        directorName.textColor = UIColor.lightGray
        
        // Section labels styling (e.g., Cast, Writers, Directors)
        let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cast.font = sectionFont
        writers.font = sectionFont
        directors.font = sectionFont
        cast.textColor = UIColor.white
        writers.textColor = UIColor.white
        directors.textColor = UIColor.white
        
        // Description label styling
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        descriptionLabel.textColor = UIColor.white
        
        // Description text view background color
        descriptionText.backgroundColor =  UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        descriptionText.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionText.textColor = UIColor.lightGray
        descriptionText.layer.cornerRadius = 10
        
        // Favorite icon color and size constraints
        favoriteIcon.tintColor = .red
        favoriteIcon.translatesAutoresizingMaskIntoConstraints = false
        favoriteIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        favoriteIcon.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        favoriteIcon.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        favoriteIcon.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        moviePoster.layer.cornerRadius = 10
        moviePoster.clipsToBounds = true
    }
    
    func addDescriptionDivider() {
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
 }

