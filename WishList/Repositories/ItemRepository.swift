//
//  ItemRepository.swift
//  WishList
//
//  Created by Marko Kos on 18.01.2023..
//

import Foundation
import CoreData
import UIKit

protocol ItemRepositoryInterface {
    func getAll(search: String?, predicate: NSPredicate?, sortType: ItemSortType?) -> [Item]
    func create(name: String?, categories: String?, website: String?, price: String?, images: [UIImage]?)
    func update(_ item: Item)
    func duplicate(_ item: Item)
    func delete(_ item: Item) -> Result<Bool, Error>
    func archive(_ item: Item)
    func unarchive(_ item: Item)
    func addCategory(_ item: Item, categoryName: String)
    func addCategory(_ item: Item, category: Category)
    func removeCategory(_ item: Item, category: Category)
    func toggleCategory(_ item: Item, category: Category)
}

class ItemCoreDataRepository: ItemRepositoryInterface {
    
    let context = CoreDataManager.shared.context
    
    func getAll(search: String?, predicate: NSPredicate?, sortType: ItemSortType?) -> [Item] {
        do {
            let request = Item.fetchRequest() as NSFetchRequest<Item>
            
            request.predicate = predicate
        
            if let sortType {
                var sort: NSSortDescriptor?
                
                switch sortType {
                case .title:
                    sort = NSSortDescriptor(key: "name", ascending: true)
                case .newest:
                    sort = NSSortDescriptor(key: "createdDate", ascending: false)
                case .oldest:
                    sort = NSSortDescriptor(key: "createdDate", ascending: true)
                }
                
                if let sort {
                    request.sortDescriptors = [sort]
                }
            }
            
            return try context.fetch(request)
        } catch {
            print("getItems error")
            return []
        }
    }
    
    func create(name: String?, categories: String?, website: String?, price: String?, images: [UIImage]?) {
        let item = Item(context: context)
        
        item.name = name
        
        if let category = categories,
           category.isEmpty {
            // TODO: Vidjeti što s ovim
            //            item.categories = nil
            print("categories is empty")
        } else {
            let categoriesArr = categories?.components(separatedBy: ", ")
            print("categories is entered")
            
            // TODO: Vidjeti što s ovim
            //            item.categories = nil
            if let categoriesArr {
                addCategories(item, categories: categoriesArr)
            }
        }
        
        if let images = images {
            addImages(item: item, images: images)
        }
        
        item.website = website
        
        if let price = price,
           !price.isEmpty {
            item.price = NSDecimalNumber(string: price, locale: Locale(identifier: "hr_HR"))
        }
        item.localeIdentifier = "hr_HR"
        
        item.createdDate = Date()
        
        do {
            try context.save()
        } catch {
            print("create error")
        }
    }
    
    func update(_ item: Item) {
        // TODO: update
    }
    
    func duplicate(_ item: Item) {
        // TODO: duplicate
    }
    
    func delete(_ item: Item) -> Result<Bool, Error> {
        do {
            context.delete(item)
            try context.save()
            return .success(true)
        } catch {
            print("delete error")
            return .failure(error)
        }
    }
    
    func archive(_ item: Item) {
        do {
            item.isArchived = true
            try context.save()
        } catch {
            print("archive error")
        }
    }
    
    func unarchive(_ item: Item) {
        do {
            item.isArchived = false
            try context.save()
        } catch {
            print("unarchive error")
        }
    }
    
    func addCategory(_ item: Item, categoryName: String) {
        do {
            let category = Category(context: context)
            category.name = categoryName
            item.addToCategories(category)
            try context.save()
        } catch {
            print("addCategory error")
        }
    }
    
    func addCategory(_ item: Item, category: Category) {
        do {
            item.addToCategories(category)
            try context.save()
        } catch {
            print("addCategory error")
        }
    }
    
    func removeCategory(_ item: Item, category: Category) {
        do {
            item.removeFromCategories(category)
            try context.save()
        } catch {
            print("removeCategory error")
        }
    }
    
    func toggleCategory(_ item: Item, category: Category) {
        do {
            guard let itemCategories = item.categories else {
                return
            }
            
            if itemCategories.contains(category) {
                item.removeFromCategories(category)
            } else {
                item.addToCategories(category)
            }
            
            try context.save()
        } catch {
            print("toggleCategory error")
        }
    }
    
}

// MARK: - Helpers

extension ItemCoreDataRepository {
    
    private func addImages(item: Item, images: [UIImage]) {
        images.forEach { image in
            let itemImage = ItemImage(context: context)
            itemImage.image = image.jpegData(compressionQuality: 0.9)
            item.addToImages(itemImage)
        }
    }
    
    private func addCategories(_ item: Item, categories: [String]) {
        for categoryStr in categories {
            let category = Category(context: context)
            category.name = categoryStr
            item.addToCategories(category)
        }
    }
    
}
