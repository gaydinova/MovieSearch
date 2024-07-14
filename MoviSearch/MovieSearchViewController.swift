//
//  ViewController.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 6/29/24.
//

import UIKit
import Nuke
import NukeExtensions
import CoreData

class MovieSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var findMovieLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favoritesScrollView: UIScrollView!
    @IBOutlet weak var favoritesStackView: UIStackView!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var favoritesLabelHorizontalStackView: UIStackView!
    
    @IBOutlet weak var searchBarStackView: UIStackView!
    
    var managedObjectContext: NSManagedObjectContext?
    var noResultsLabel: UILabel!
   
    var allMovies: [Movie] = []
    var filteredMovies: [Movie] = []
    let movieService = MovieService()
    var movieDetails: MovieDetails?
    var favorites: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdate), name: .didUpdateFavorites, object: nil)
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint.isActive = true
        tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        favoritesScrollView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.heightAnchor.constraint(equalTo: favoritesScrollView.heightAnchor).isActive = true
        favoritesStackView.distribution = .equalSpacing
        favoritesStackView.alignment = .leading
        favoritesStackView.spacing = 8
        favoritesScrollView.showsHorizontalScrollIndicator = true
        setupNoResultsLabel()
        styleUI()
        applyTitleStylingToFavorites()
        hideTableView()
        fetchFavorites()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear called")
        fetchFavorites()
    }
    
    @objc func handleFavoritesUpdate() {
        print("handleFavoritesUpdate called")
        // Refetch favorites when notification is received
          fetchFavorites()
      }
    
    func styleUI() {
        findMovieLabel.font = UIFont.boldSystemFont(ofSize: 24)
        findMovieLabel.textColor = UIColor.white
        searchBar.barTintColor = UIColor.black
        searchBar.tintColor = UIColor.white
        searchBar.searchTextField.backgroundColor = UIColor.darkGray
        searchBar.searchTextField.textColor = UIColor.white
        let titleFont = UIFont.boldSystemFont(ofSize: 16)
        let titleColor = UIColor.white
        
        for view in favoritesStackView.arrangedSubviews {
            if let stackView = view as? UIStackView {
                for subview in stackView.arrangedSubviews {
                    if let label = subview as? UILabel {
                        label.font = titleFont
                        label.textColor = titleColor
                    }
                }
            }
        }
    }
    
    func fetchFavorites() {
        print("fetchFavorites called")
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available.")
            return
        }
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            let favorites = try context.fetch(fetchRequest)
            self.favorites = Set(favorites.map { Int($0.id) })
            print("Fetched favorites: \(self.favorites)")
            updateFavoritesUI()
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }
    
    func setupFavorites() {
        print("Set up favroites called")
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavorites(_:)), name: .didUpdateFavorites, object: nil)
    }
    
    @objc func updateFavorites(_ notification: Notification) {
        print("updateFavorites called")
        guard let userInfo = notification.userInfo,
              let movieId = userInfo["movieId"] as? Int,
              let isFavorite = userInfo["isFavorite"] as? Bool else { 
            print("failed to get favorites info")
            return }
        
        if isFavorite {
            favorites.insert(movieId)
        } else {
            favorites.remove(movieId)
        }
        print("Favorites updated: \(favorites)")
        updateFavoritesUI()
    }
    
    func updateFavoritesUI() {
           print("updateFavoritesUI called")
           favoritesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
           
           guard let context = managedObjectContext else {
               print("Managed Object Context is not available.")
               return
           }
           
           // Perform a fetch request to get all favorited movies
           let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
           
           do {
               let favorites = try context.fetch(fetchRequest)
               print("Fetched favorite movies from Core Data: \(favorites.count)")
               favoritesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
               
               // Iterate over each favorited movie and create a view for it
               for favorited in favorites {
                   print("Creating view for favorited movie: \(favorited.title ?? "No Title")")
                   createMovieView(for: favorited)
               }
               
           } catch let error as NSError {
               print("Could not fetch favorites: \(error), \(error.userInfo)")
           }
       }
    
    func createMovieView(for favoriteMovie: FavoriteMovie) {
        let moviePosterView = UIImageView()
        if let posterPath = favoriteMovie.posterPath, let posterUrl = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
            NukeExtensions.loadImage(with: posterUrl, into: moviePosterView)
        }
        moviePosterView.contentMode = .scaleAspectFill
        moviePosterView.clipsToBounds = true
        moviePosterView.layer.cornerRadius = 10
        moviePosterView.translatesAutoresizingMaskIntoConstraints = false
        moviePosterView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        moviePosterView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        let movieTitleLabel = UILabel()
        movieTitleLabel.text = favoriteMovie.title
        movieTitleLabel.textColor = UIColor.white
        movieTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        movieTitleLabel.textAlignment = .center
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.numberOfLines = 0
        movieTitleLabel.lineBreakMode = .byWordWrapping
        movieTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
       
        let movieContainer = UIStackView(arrangedSubviews: [moviePosterView, movieTitleLabel])
        movieContainer.axis = .vertical
        movieContainer.alignment = .fill
        movieContainer.spacing = 3
        movieContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Add tap gesture recognizer to the container
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(movieTapped(_:)))
        movieContainer.addGestureRecognizer(tapGesture)
        movieContainer.isUserInteractionEnabled = true
        movieContainer.tag = Int(favoriteMovie.id)
        favoritesStackView.addArrangedSubview(movieContainer)
    }
    
    @objc func movieTapped(_ sender: UITapGestureRecognizer) {
        guard let movieId = sender.view?.tag else { return }
        getMovieDetails(movieId: movieId) { [weak self] movieDetails in
            guard let movieDetails = movieDetails else { return }
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "showMovieDetail", sender: movieDetails)
            }
        }
    }
    
    func getMovieDetails(movieId: Int, completion: @escaping (MovieDetails?) -> Void) {
          movieService.getMovieDetails(movieId: movieId) { movieDetails in
              completion(movieDetails)
          }
      }
    
    func setupNoResultsLabel() {
        noResultsLabel = UILabel()
        noResultsLabel.text = "No Movies Found"
        noResultsLabel.textColor = .white
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noResultsLabel)
        
        let bottomPadding: CGFloat = -130.0
        
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: bottomPadding)
        ])
        noResultsLabel.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = []
            hideTableView()
            tableView.reloadData()
            self.noResultsLabel.isHidden = true
        } else {
            movieService.searchMovies(query: searchText) { [weak self] movies in
                DispatchQueue.main.async {
                    if let movies = movies {
                        print("Search results: \(movies)")
                        self?.filteredMovies = movies
                        self?.noResultsLabel.isHidden = true
                    } else {
                        print("No movies found")
                        self?.filteredMovies = []
                        self?.noResultsLabel.isHidden = false
                    }
                    self?.tableView.reloadData()
                    self?.updateTableViewHeight()
                    if self?.filteredMovies.isEmpty == true {
                        self?.hideTableView()
                    } else {
                        self?.showTableView()
                    }
                }
            }
        }
    }
    
    private func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    private func hideTableView() {
        tableViewHeightConstraint.constant = 0
        tableView.isHidden = true
    }
    
    private func showTableView() {
        tableView.isHidden = false
        tableViewHeightConstraint.constant = tableView.contentSize.height
        tableView.layoutIfNeeded()
        mainStackView.setCustomSpacing(5, after: searchBarStackView)
    }
    
    func applyTitleStylingToFavorites() {
        let titleFont = UIFont.boldSystemFont(ofSize: 16)
        let titleColor = UIColor.white
        
        for view in favoritesStackView.arrangedSubviews {
            if let stackView = view as? UIStackView {
                for subview in stackView.arrangedSubviews {
                    if let label = subview as? UILabel {
                        label.font = titleFont
                        label.textColor = titleColor
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue identifier: \(String(describing: segue.identifier))")
        
        if segue.identifier == "showMovieDetail" {
            print("Segue identifier matches")
            
            if let destinationVC = segue.destination as? MovieDetailsViewController {
                print("Destination is MovieDetailsViewController")
                
                if let movieDetails = sender as? MovieDetails {
                    print("Sender is MovieDetails")
                    destinationVC.movieDetails = movieDetails
                    destinationVC.managedObjectContext = managedObjectContext
                    print("Preparing segue for movie: \(movieDetails)")
                } else {
                    print("Sender is not MovieDetails")
                }
            } else {
                print("Destination is not MovieDetailsViewController")
            }
        } else {
            print("Segue identifier does not match")
        }
    }
}

extension MovieSearchViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           guard indexPath.row < filteredMovies.count else {
               fatalError("Index out of range. Ensure that filteredMovies array and table view are synchronized.")
           }
           
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           cell.textLabel?.text = filteredMovies[indexPath.row].title
           return cell
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = filteredMovies[indexPath.row]
        print("Selected movie: \(selectedMovie)")
        movieService.getMovieDetails(movieId: selectedMovie.id) { [weak self] movieDetails in
            DispatchQueue.main.async {
                print("Movie details callback")
                if let movieDetails = movieDetails {
                    print("Fetched movie details: \(movieDetails)")
                    print("Type of movieDetails: \(type(of: movieDetails))")
                    self?.performSegue(withIdentifier: "showMovieDetail", sender: movieDetails)
                    print("Performing segue with movie details")
                } else {
                    print("Failed to fetch movie details")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension Notification.Name {
    static let didUpdateFavorites = Notification.Name("didUpdateFavorites")
}
