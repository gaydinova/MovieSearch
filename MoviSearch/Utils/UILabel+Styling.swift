//
//  UILabel+Styling.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/21/24.
//

import Foundation
import UIKit

extension UILabel {
    func applyTitleStyle() {
        self.font = UIFont.boldSystemFont(ofSize: 24)
        self.textColor = UIColor.white
        self.numberOfLines = 0
        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func applySubtitleStyle(fontSize: CGFloat = 14) {
        self.font = UIFont.italicSystemFont(ofSize: fontSize)
        self.textColor = UIColor.lightGray
    }
    
    func applyBodyStyle() {
        self.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.textColor = UIColor.lightGray
    }
    
    func applySectionTitleStyle() {
        self.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.textColor = UIColor.white
    }
}
