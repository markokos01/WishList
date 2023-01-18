//
//  ItemFilter.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import Foundation
import UIKit

enum ItemFilterType {
    case all
    case mostRecent
    case archived
    case uncategorized
    case category
}

struct ItemFilter {
    let type: ItemFilterType
    let title: String?
    let predicate: NSPredicate?
    let image: UIImage?
}
