//
//  ViewController.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 6/29/24.
//

import UIKit

class MovieSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var findMovieLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favoritesScrollView: UIScrollView!
    @IBOutlet weak var favoritesStackView: UIStackView!
    @IBOutlet weak var favoritesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    struct Movie {
        let imageName: String
        let title: String
        let description: String
        let year: String
        let genre: String
        let duration: String
        let directors: String
        let writers: String
        let cast: String
    }
    
    let movies = [
        Movie(imageName: "lion-king", title: "The Lion King", description: "A young lion prince flees his kingdom after the murder of his father.", year: "1994", genre: "Animation, Adventure, Drama", duration: "88 min", directors: "Roger Allers, Rob Minkoff", writers: "Irene Mecchi, Jonathan Roberts", cast: "Matthew Broderick, Jeremy Irons, James Earl Jones"),
        Movie(imageName: "titanic", title: "Titanic", description: "A love story unfolds on the ill-fated RMS Titanic.", year: "1997", genre: "Drama, Romance", duration: "195 min", directors: "James Cameron", writers: "James Cameron", cast: "Leonardo DiCaprio, Kate Winslet, Billy Zane"),
        Movie(imageName: "lion-king-2", title: "The Lion King 2", description: "Simba's daughter Kiara discovers love with Kovu.", year: "1998", genre: "Animation, Adventure, Drama", duration: "81 min", directors: "Darrell Rooney, Rob LaDuca", writers: "Flip Kobler, Cindy Marcus", cast: "Matthew Broderick, Neve Campbell, Andy Dick")
    ]
    
    var filteredMovies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        filteredMovies = movies
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint.isActive = true
        tableView.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        favoritesStackView.translatesAutoresizingMaskIntoConstraints = false
        favoritesStackView.spacing = 8
        favoritesStackView.axis = .horizontal
        styleUI()
        setupFavorites()
        applyTitleStylingToFavorites()
        hideTableView()
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
    
    func setupFavorites() {
        favoritesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, movie) in movies.enumerated() {
            let moviePosterView = UIImageView()
            moviePosterView.image = UIImage(named: movie.imageName)
            moviePosterView.contentMode = .scaleAspectFill
            moviePosterView.clipsToBounds = true
            moviePosterView.layer.cornerRadius = 10
            moviePosterView.translatesAutoresizingMaskIntoConstraints = false
            moviePosterView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            moviePosterView.widthAnchor.constraint(equalToConstant: 400).isActive = true
            
            let movieTitleLabel = UILabel()
            movieTitleLabel.text = movie.title
            movieTitleLabel.textAlignment = .center
            movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            movieTitleLabel.numberOfLines = 0
            movieTitleLabel.isUserInteractionEnabled = true
            movieTitleLabel.tag = index
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(movieTapped(_:)))
            movieTitleLabel.addGestureRecognizer(tapGesture)
            
            let movieContainer = UIStackView(arrangedSubviews: [moviePosterView, movieTitleLabel])
            movieContainer.axis = .vertical
            movieContainer.alignment = .center
            movieContainer.spacing = 0
            movieContainer.translatesAutoresizingMaskIntoConstraints = false
            movieContainer.setCustomSpacing(-160, after: moviePosterView)
            favoritesStackView.addArrangedSubview(movieContainer)
        }
        
        favoritesStackView.layoutIfNeeded()
    }
    
    @objc func movieTapped(_ sender: UITapGestureRecognizer) {
        if let index = sender.view?.tag {
            let selectedMovie = movies[index]
            performSegue(withIdentifier: "showMovieDetail", sender: selectedMovie)
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // Using UISearchBar from storyboard
        if searchText.isEmpty {
            filteredMovies = movies
            hideTableView()
        } else {
            filteredMovies = movies.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
            updateTableViewHeight()
            if filteredMovies.isEmpty {
                hideTableView()
            } else {
                showTableView()
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
        mainStackView.spacing = 15
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
        if segue.identifier == "showMovieDetail",
           let destinationVC = segue.destination as? MovieDetailsViewController,
           let movie = sender as? Movie {
            destinationVC.movieTitle = movie.title
            destinationVC.imageName = movie.imageName
            destinationVC.moviesDescription = movie.description
            destinationVC.year = movie.year
            destinationVC.genre = movie.genre
            destinationVC.duration = movie.duration
            destinationVC.movieDirectors = movie.directors
            destinationVC.movieWriters = movie.writers
            destinationVC.movieCast = movie.cast
        }
    }
}

extension MovieSearchViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredMovies[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
   
    }
}
