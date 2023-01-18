//
//  WishlistViewModel.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import Foundation
import UIKit

enum WishlistSection {
    case actions
    case filters
    case categories
    case settings
}

enum WishlistItemActionType {
    case newItem
    case filter
    case settings
}

struct WishlistItem: Hashable {
    let actionType: WishlistItemActionType
    let image: UIImage?
    let title: String
    var hasDisclosureIndicator: Bool = true
    var canDelete: Bool = false
}

class WishlistViewModel {
    
    var actionItems = [
        WishlistItem(actionType: .newItem, image: UIImage(systemName: "plus.circle"), title: "New item", hasDisclosureIndicator: false),
    ]
    
    var filterItems = [
        WishlistItem(actionType: .filter, image: UIImage(systemName: "archivebox"), title: "All"),
        WishlistItem(actionType: .filter, image: UIImage(systemName: "clock"), title: "Most recent"),
        WishlistItem(actionType: .filter, image: UIImage(systemName: "archivebox"), title: "Archived"),
        WishlistItem(actionType: .filter, image: UIImage(systemName: "tag.slash"), title: "Uncategorized"),
    ]

    var categoriesItems = [
        WishlistItem(actionType: .filter, image: UIImage(systemName: "tag"), title: "Tag 1", canDelete: true),
        WishlistItem(actionType: .filter, image: UIImage(systemName: "tag"), title: "Tag 2", canDelete: true),
        WishlistItem(actionType: .filter, image: UIImage(systemName: "tag"), title: "Tag 3", canDelete: true)
    ]
    
    var settingsItems = [
        WishlistItem(actionType: .settings, image: UIImage(systemName: "ellipsis.circle.fill"), title: "Settings")
    ]
    
}
