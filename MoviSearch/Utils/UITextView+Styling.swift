//
//  UITextView+Styling.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/21/24.
//

import Foundation
import UIKit

extension UITextView {
    func applyDescriptionStyle() {
        self.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.0)
        self.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.textColor = UIColor.lightGray
        self.layer.cornerRadius = 10
    }
}

