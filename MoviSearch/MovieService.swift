//
//  MovieService.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/9/24.
//

import Foundation
import UIKit
import os

class MovieService: NSObject, URLSessionDelegate {
    private let apiKey = "ac986bef4220b424c09ded978c8b078d"
    private let authToken = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhYzk4NmJlZjQyMjBiNDI0" +
        "YzA5ZGVkOTc4YzhiMDc4ZCIsIm5iZiI6MTcyMDU3NjMwNS41ODkxMzksInN1YiI6IjY1MDEwMjVlZDdkY2QyMDBjNTM2ZDkz" +
    "OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.lJz2VQLa_eyyrsO8XpkyV9Q2a3f5Nrl-yqZVkpGag1k"
   
    private let baseUrl = "https://api.themoviedb.org/3"
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MovieService")
   
    private lazy var urlSession: URLSession = {
          let configuration = URLSessionConfiguration.default
          return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
      }()
    
    func searchMovies(query: String, completion: @escaping (Result<[Movie], MovieServiceError>) -> Void) {
        let urlString = "\(baseUrl)/search/movie"
        guard var components = URLComponents(string: urlString) else {
            completion(.failure(.urlCreationFailed))
            return
        }

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        guard let url = components.url else { 
            completion(.failure(.urlCreationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": authToken
        ]

        let task = urlSession.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                self?.logger.error("Request failed: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let data = data else {
                self?.logger.error("No data received.")
                completion(.failure(.noData))
                return
            }

            do {
                let result = try JSONDecoder().decode(MovieSearchResult.self, from: data)
                completion(.success(result.results))
            } catch {
                self?.logger.error("Decoding error: \(error.localizedDescription)")
                completion(.failure(.decodingFailed(error)))
            }
        }
        task.resume()
    }

    func getMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetails, MovieServiceError>) -> Void) {
        let urlString = "\(baseUrl)/movie/\(movieId)"
        guard var components = URLComponents(string: urlString) else {
            completion(.failure(.urlCreationFailed))
            return
        }

        components.queryItems = [
            URLQueryItem(name: "append_to_response", value: "credits"),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        guard let url = components.url else {
            completion(.failure(.urlCreationFailed))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": authToken
        ]

        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.logger.error("Error fetching movie details: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let data = data else {
                self?.logger.error("No data returned.")
                completion(.failure(.noData))
                return
            }

            do {
                let movie = try JSONDecoder().decode(MovieDetails.self, from: data)
                print("Fetched movie details: \(movie)")
                completion(.success(movie))
            } catch {
                self?.logger.error("Error decoding movie details: \(error.localizedDescription)")
                completion(.failure(.decodingFailed(error)))
            }
        }
        task.resume()
    }
}
