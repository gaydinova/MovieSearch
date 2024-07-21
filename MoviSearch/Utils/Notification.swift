//
//  Notification.swift
//  MoviSearch
//
//  Created by Gunel Aydinova on 7/21/24.
//

import Foundation

/*
  Notification name for when the favorites list is updated
  This notification is posted whenever a movie is added to or removed from the favorites list.
  Observers can use this notification to update their UI or perform other actions in response
  to changes in the favorites list.
 */

extension Notification.Name {
    static let didUpdateFavorites = Notification.Name("didUpdateFavorites")
}
