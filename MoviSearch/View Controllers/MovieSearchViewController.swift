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

class MovieSearchViewController: UIViewController, UISearchBarDelegate,
                                    UITableViewDataSource, UITableViewDelegate, AlertPresentable {
    
    // MARK: - Properties
    
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
    var activityIndicator: UIActivityIndicatorView!
    var activityIndicatorBackground: UIView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObservers()
        setupActivityIndicator()
        fetchFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
        clearSearchAndHideTableView()
    }
    
    // MARK: Setup Methods
    private func setupView() {
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        setupSearchBar()
        setupTableView()
        setupFavoritesScrollView()
        setupNoResultsLabel()
        setupEmptyStateLabel()
        styleUI()
        applyTitleStylingToFavorites()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoritesUpdate), name: .didUpdateFavorites, object: nil)
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.black
        searchBar.tintColor = UIColor.white
        searchBar.searchTextField.backgroundColor = UIColor.darkGray
        searchBar.searchTextField.textColor = UIColor.white
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint.isActive = true
        tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
    }
    
    private func setupFavoritesScrollView() {
        favoritesScrollView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.heightAnchor.constraint(equalTo: favoritesScrollView.heightAnchor).isActive = true
        favoritesStackView.distribution = .equalSpacing
        favoritesStackView.alignment = .leading
        favoritesStackView.spacing = 8
        favoritesScrollView.showsHorizontalScrollIndicator = true
    }
    
    private func setupNoResultsLabel() {
          noResultsLabel = UILabel()
          noResultsLabel.text = "No Movies Found"
          noResultsLabel.font = UIFont.boldSystemFont(ofSize: 24)
          noResultsLabel.textColor = UIColor.white
          noResultsLabel.textAlignment = .center
          noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(noResultsLabel)

          NSLayoutConstraint.activate([
              noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -130)
          ])
          noResultsLabel.isHidden = true
      }
    
    private func setupEmptyStateLabel() {
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "You have no favorite movies yet."
        emptyStateLabel.applyTitleStyle()
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        emptyStateLabel.isHidden = true
    }
    
    func setupFavorites() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavorites(_:)), name: .didUpdateFavorites, object: nil)
    }
    
    private func styleUI() {
        findMovieLabel.applyTitleStyle()
        favoritesLabel.applySectionTitleStyle()
        applyTitleStylingToFavorites()
    }
    
    private func setupActivityIndicator() {
         activityIndicatorBackground = UIView()
         activityIndicatorBackground.backgroundColor = UIColor(white: 0, alpha: 0.7)
         activityIndicatorBackground.translatesAutoresizingMaskIntoConstraints = false
         activityIndicatorBackground.isHidden = true
         view.addSubview(activityIndicatorBackground)
         
         activityIndicator = UIActivityIndicatorView(style: .large)
         activityIndicator.color = .white
         activityIndicator.translatesAutoresizingMaskIntoConstraints = false
         activityIndicatorBackground.addSubview(activityIndicator)
         
         NSLayoutConstraint.activate([
             activityIndicatorBackground.topAnchor.constraint(equalTo: view.topAnchor),
             activityIndicatorBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             activityIndicatorBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             activityIndicatorBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorBackground.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorBackground.centerYAnchor)
         ])
     }
    
    // MARK: - UI Update Methods
    
    private func applyTitleStylingToFavorites() {
        for view in favoritesStackView.arrangedSubviews {
            if let stackView = view as? UIStackView {
                for subview in stackView.arrangedSubviews {
                    if let label = subview as? UILabel {
                        label.applySectionTitleStyle()
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
    
    // MARK: - Event Handlers
    
    @objc func handleFavoritesUpdate() {
        // Refetch favorites when notification is received
        fetchFavorites()
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
    
    @objc func movieTapped(_ sender: UITapGestureRecognizer) {
        guard let movieId = sender.view?.tag else { return }
        showActivityIndicator()
        getMovieDetails(movieId: movieId) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                switch result {
                case .success(let movieDetails):
                    self?.performSegue(withIdentifier: "showMovieDetail", sender: movieDetails)
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    private func createMovieView(for favoriteMovie: FavoriteMovie) {
        let moviePosterView = UIImageView()
        if let posterPath = favoriteMovie.posterPath {
            ImageLoader.shared.loadImage(with: posterPath, into: moviePosterView)
        }
        
        moviePosterView.applyPosterStyle()
        moviePosterView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        moviePosterView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        
        let movieTitleLabel = UILabel()
        movieTitleLabel.text = favoriteMovie.title
        movieTitleLabel.applySectionTitleStyle()
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
    
    func getMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetails, MovieServiceError>) -> Void) {
        movieService.getMovieDetails(movieId: movieId, completion: completion)
    }
    
    // MARK: - UISearchBarDelegate Methods
    
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
                        self?.noResultsLabel.isHidden = !movies.isEmpty
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
    
    // MARK: - Navigation
    
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

// MARK: - UITableViewDataSource and UITableViewDelegate Methods

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
         showActivityIndicator()
         movieService.getMovieDetails(movieId: selectedMovie.id) { [weak self] result in
             DispatchQueue.main.async {
                 self?.hideActivityIndicator()
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

// MARK: - Activity Indicator Methods

extension MovieSearchViewController {
    private func showActivityIndicator() {
         activityIndicatorBackground.isHidden = false
         activityIndicator.startAnimating()
     }

     private func hideActivityIndicator() {
         activityIndicatorBackground.isHidden = true
         activityIndicator.stopAnimating()
     }
}
