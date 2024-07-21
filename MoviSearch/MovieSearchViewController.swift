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

class MovieSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, AlertPresentable {
    
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
    
    @IBOutlet weak var seeAllButton: UIButton!
    
    var managedObjectContext: NSManagedObjectContext?
    var noResultsLabel: UILabel!
    var emptyStateLabel: UILabel!
    
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
        setupEmptyStateLabel()
        styleUI()
        applyTitleStylingToFavorites()
        hideTableView()
        fetchFavorites()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
        clearSearchAndHideTableView()
    }
    
    @objc func handleFavoritesUpdate() {
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
        guard let context = managedObjectContext else {
            return
        }
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            let favorites = try context.fetch(fetchRequest)
            self.favorites = Set(favorites.map { Int($0.id) })
            updateFavoritesUI()
        } catch {
            showErrorAlert(message: "Failed to fetch favorites: \(error.localizedDescription)")
        }
    }
    
    func setupFavorites() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavorites(_:)), name: .didUpdateFavorites, object: nil)
    }
    
    @objc func updateFavorites(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let movieId = userInfo["movieId"] as? Int,
              let isFavorite = userInfo["isFavorite"] as? Bool else {
            return
        }

        if isFavorite {
            favorites.insert(movieId)
        } else {
            favorites.remove(movieId)
        }
        updateFavoritesUI()
    }
    
    func updateFavoritesUI() {
        favoritesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let context = managedObjectContext else {
            return
        }
        
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            let favorites = try context.fetch(fetchRequest)
            if favorites.isEmpty {
                emptyStateLabel.isHidden = false
                favoritesLabelHorizontalStackView.isHidden = true
            } else {
                emptyStateLabel.isHidden = true
                favoritesLabelHorizontalStackView.isHidden = false
                for favorited in favorites {
                    createMovieView(for: favorited)
                }
            }
        } catch let error as NSError {
            showErrorAlert(message: "Could not fetch favorites: \(error.localizedDescription)")
        }
    }
    
    func createMovieView(for favoriteMovie: FavoriteMovie) {
        let moviePosterView = UIImageView()
        if let posterPath = favoriteMovie.posterPath {
            ImageLoader.shared.loadImage(with: posterPath, into: moviePosterView)
        }
        
        moviePosterView.contentMode = .scaleAspectFill
        moviePosterView.clipsToBounds = true
        moviePosterView.layer.cornerRadius = 10
        moviePosterView.translatesAutoresizingMaskIntoConstraints = false
        moviePosterView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        moviePosterView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        
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
        movieContainer.spacing = 7
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
        getMovieDetails(movieId: movieId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movieDetails):
                    self?.performSegue(withIdentifier: "showMovieDetail", sender: movieDetails)
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    func getMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetails, MovieServiceError>) -> Void) {
        movieService.getMovieDetails(movieId: movieId, completion: completion)
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
    
    func setupEmptyStateLabel() {
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "You have no favorite movies yet."
        emptyStateLabel.textColor = .white
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.font = UIFont.boldSystemFont(ofSize: 18)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        emptyStateLabel.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredMovies = []
            hideTableView()
            tableView.reloadData()
            noResultsLabel.isHidden = true
            emptyStateLabel.isHidden = favorites.isEmpty ? false : true
        } else {
            emptyStateLabel.isHidden = true
            movieService.searchMovies(query: searchText) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let movies):
                        self?.filteredMovies = movies
                        self?.noResultsLabel.isHidden = true
                    case .failure:
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
    
    private func clearSearchAndHideTableView() {
          searchBar.text = ""
          filteredMovies.removeAll()
          tableView.reloadData()
          hideTableView()
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
        if segue.identifier == "showMovieDetail" {
            if let destinationVC = segue.destination as? MovieDetailsViewController,
               let movieDetails = sender as? MovieDetails {
                destinationVC.movieDetails = movieDetails
                destinationVC.isFromFavorites = false
                destinationVC.managedObjectContext = managedObjectContext
            } else {
                showErrorAlert(message: "Failed to pass movie details.")
            }
        } else if segue.identifier == "showFavorites" {
            if let favoritesVC = segue.destination as? FavoritesViewController {
                favoritesVC.managedObjectContext = managedObjectContext
            }
        }
    }
}

extension MovieSearchViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < filteredMovies.count else {
            showErrorAlert(message: "Something went wrong. Please try again.")
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                  cell.textLabel?.text = "Error: Something went wrong"
                  return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredMovies[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = filteredMovies[indexPath.row]
        movieService.getMovieDetails(movieId: selectedMovie.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movieDetails):
                    self?.performSegue(withIdentifier: "showMovieDetail", sender: movieDetails)
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
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
