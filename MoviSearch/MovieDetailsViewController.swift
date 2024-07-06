//
//  MovieDetailViewController.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/4/24.
//

import Foundation
import UIKit

class MovieDetailsViewController: UIViewController {
    
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
    
    
    
    var movieTitle: String?
    var imageName: String?
    var moviesDescription: String?
    var year: String?
    var genre: String?
    var duration: String?
    var movieDirectors: String?
    var movieWriters: String?
    var movieCast: String?
    
    override func viewDidLoad() {
            super.viewDidLoad()
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)

            movieName.text = movieTitle
            descriptionText.text = moviesDescription
            movieYear.text = year
            movieGenre.text = genre
            movieDuration.text = duration
            writerName.text = movieWriters
            castName.text = movieCast
            directorName.text = movieDirectors
            
            if let imageName = imageName {
                moviePoster.image = UIImage(named: imageName)
            }
        styleUI()
        addDescriptionDivider()
        
       
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
           
           // Set constraints for the divider
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

