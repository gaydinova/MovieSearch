//
//  MovieServiceError.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/20/24.
//

import Foundation

enum MovieServiceError: Error, LocalizedError {
    case urlCreationFailed
    case requestFailed(Error)
    case invalidResponse
    case noData
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .urlCreationFailed:
            return "Failed to create URL."
        case .requestFailed(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid response from server."
        case .noData:
            return "No data received."
        case .decodingFailed(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
