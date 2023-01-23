//
//  Item.swift
//  WishList
//
//  Created by Marko Kos on 05.01.2023..
//

import Foundation
import UIKit

extension Item {
    
    public static var defaultImage = UIImage(named: "image_default")
    public static var defaultTitle = "(No Title)"
    
    var isUncategorized: Bool {
        return categories?.count == 0
    }
    
    var categoriesAsString: String? {
        guard categories != nil && isUncategorized == false else {
            return nil
        }
        
        let categoriesSet = categories as! Set<Category>
        let sortedCategories = categoriesSet.sorted { $0.name ?? "" < $1.name ?? "" }
        return sortedCategories.map { $0.name ?? "" }.lazy.joined(separator: ", ")
    }
    
    var firstItemImage: ItemImage? {
        return (images?.allObjects as? [ItemImage])?.first
    }
    
    var hasItemFirstImage: Bool {
        return self.firstItemImage != nil
    }
    
    var isPriceZero: Bool {
        return price == 0
    }
    
}

