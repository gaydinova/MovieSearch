//
//  Movie.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/9/24.
//

import Foundation
import UIKit

struct MovieSearchResult: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String?
    let releaseDate: String?
    let genreIds: [Int]?
    let originalLanguage: String?
    let originalTitle: String?
    let popularity: Double?
    let voteAverage: Double?
    let voteCount: Int?
    let video: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, video
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

struct MovieDetails: Codable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let genres: [Genre]
    let posterPath: String?
    let runtime: Int?
    let credits: Credits?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, runtime, credits
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct Credits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable {
    let name: String
}

struct CrewMember: Codable {
    let name: String
    let job: String
}
