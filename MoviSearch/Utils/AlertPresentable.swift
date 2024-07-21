//
//  ErrorAlert.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/20/24.
//

import Foundation
import UIKit

protocol AlertPresentable {
    func showErrorAlert(message: String)
}

extension AlertPresentable where Self: UIViewController {
    func showErrorAlert(message: String) {
         let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion: nil)
     }
}
