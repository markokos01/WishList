//
//  ItemSort.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import Foundation
import UIKit

enum ItemSortType {
    case title
    case newest
    case oldest
}

struct ItemSort {
    let type: ItemSortType
    let title: String
    let sortDescriptior: NSSortDescriptor
}
