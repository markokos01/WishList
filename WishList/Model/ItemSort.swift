//
//  ItemSort.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import Foundation
import UIKit

enum SortType {
    case title
    case newest
    case oldest
}

struct ItemSort {
    let type: SortType
    let title: String
    let sortDescriptior: NSSortDescriptor
}
