//
//  FavoritesViewController.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/16/24.
//

import Foundation
import UIKit
import CoreData

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AlertPresentable {
    
    var managedObjectContext: NSManagedObjectContext?
    var favoriteMovies: [FavoriteMovie] = []
    let movieService = MovieService()
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    override func viewDidLoad() {
        self.navigationItem.title = "My Favorites"
        favoritesTableView.dataSource = self
        favoritesTableView.delegate = self
        favoritesTableView.estimatedRowHeight = 120
        favoritesTableView.rowHeight = UITableView.automaticDimension
        favoritesTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        fetchFavorites()
    }
    
    func fetchFavorites() {
           guard let context = managedObjectContext else { return }
           let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
           do {
               favoriteMovies = try context.fetch(fetchRequest)
               favoritesTableView.reloadData()
           } catch {
               showErrorAlert(message: "Error fetching favorites: \(error.localizedDescription)")
           }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteMovieCell", for: indexPath) as? FavoriteMovieCell else {
               showErrorAlert(message: "Expected `FavoriteMovieCell` type for reuseIdentifier FavoriteMovieCell. Check the configuration in the storyboard.")
               return UITableViewCell()
           }
           let favoriteMovie = favoriteMovies[indexPath.row]
           cell.configure(with: favoriteMovie)
           return cell
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let selectedMovieID = favoriteMovies[indexPath.row].id
          movieService.getMovieDetails(movieId: Int(selectedMovieID)) { [weak self] result in
              DispatchQueue.main.async {
                  switch result {
                  case .success(let movieDetails):
                      self?.performSegue(withIdentifier: "showMovieDetail", sender: (movieDetails, true))
                  case .failure(let error):
                      self?.showErrorAlert(message: error.localizedDescription)
                  }
              }
          }
      }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
           let destinationVC = segue.destination as? MovieDetailsViewController,
           let (movieDetails, isFromFavorites) = sender as? (MovieDetails, Bool) {
                 destinationVC.movieDetails = movieDetails
                 destinationVC.isFromFavorites = isFromFavorites
             }
        }
    }

