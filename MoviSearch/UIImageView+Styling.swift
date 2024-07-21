//
//  UIImageView+Styling.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/21/24.
//

import Foundation
import UIKit

extension UIImageView {
    func applyFavoriteIconStyle() {
        self.tintColor = .red
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func applyPosterStyle() {
            self.contentMode = .scaleAspectFill
            self.clipsToBounds = true
            self.layer.cornerRadius = 10
        }
}

