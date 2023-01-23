//
//  NewItemViewModel.swift
//  WishList
//
//  Created by Marko Kos on 18.01.2023..
//

import Foundation
import UIKit

class NewItemViewModel {
    
    let itemDataSource = ItemCoreDataRepository()
    
    func addItem(name: String?, categories: String?, website: String?, price: String?, images: [UIImage]?) {
        itemDataSource.create(name: name, categories: categories, website: website, price: price, images: images)
    }
    
    func updateItem(item: Item, name: String?, categories: String?, website: String?, price: String?, image: UIImage?) {
        // TODO: updateItem
    }
    
}
