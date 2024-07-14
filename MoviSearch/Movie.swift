//
//  Movie.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/9/24.
//

import Foundation
import UIKit


struct MovieSearchResult: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int
    let title: String
    var poster_path: String 
}

struct MovieDetails: Codable {
    let id: Int
    let title: String
    let overview: String
    let release_date: String
    let genres: [Genre]
    let poster_path: String?
    let runtime: Int?
    let credits: Credits?
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
