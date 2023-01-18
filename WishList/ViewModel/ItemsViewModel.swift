//
//  ItemsViewModel.swift
//  WishList
//
//  Created by Marko Kos on 28.12.2022..
//

import Foundation
import UIKit
import CoreData

// MARK: Sorting

let itemSortOptions: [ItemSort] = [
    ItemSort(
        type: .title,
        title: "Title",
        sortDescriptior: NSSortDescriptor(key: "name", ascending: true)
    ),
    ItemSort(
        type: .newest,
        title: "Newest",
        sortDescriptior: NSSortDescriptor(key: "createdDate", ascending: true)
    ),
    ItemSort(
        type: .oldest,
        title: "Oldest",
        sortDescriptior: NSSortDescriptor(key: "createdDate", ascending: false)
    )
]

// MARK: Filtering

var itemFilterOptions: [ItemFilter] = [
    ItemFilter(
        type: .all,
        title: "All",
        predicate: nil,
        image: UIImage(systemName: "list.bullet.rectangle")
    ),
    ItemFilter(
        type: .mostRecent,
        title: "Most recent",
        predicate: nil, // TODO: Define most recent filter
        image: UIImage(systemName: "clock")
    ),
    ItemFilter(
        type: .archived,
        title: "Archived",
        predicate: NSPredicate(format: "isArchived = %d", true),
        image: UIImage(systemName: "archivebox")
    ),
    ItemFilter(
        type: .uncategorized,
        title: "Uncategorized",
        predicate: NSPredicate(format: "categories.@count == 0"),
        image: UIImage(systemName: "tag.slash")
    ),
]

// MARK: Action

enum CategoryAction {
    case filter
    case add
}

protocol ItemsViewModelDelegate: AnyObject {
    func didChangeItemsFilter()
    func didLoadItems()
    func didSaveContext()
}

class ItemsViewModel {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    weak var delegate: ItemsViewModelDelegate?
    
    var items: [Item] = []
    var categories: [Category] = []
    
    var searchBarPlaceholder = "Search"
    var extendedSearchBarPlaceholder: String {
        if let title = selectedItemFilter.title {
            return "Search in '\(title)'"
        } else {
            return "Search"
        }
    }
    
    var sortButtonTitle: String {
        return "\(self.items.count) items"
    }
    
    var selectedSortType: SortType = .newest {
        didSet {
            self.getItems()
        }
    }
    
    var isSortEnabled: Bool {
        return self.selectedItemFilter.type != .mostRecent
    }
    
    var selectedItemFilter = itemFilterOptions.first! {
        didSet {
            self.getItems()
            self.delegate?.didChangeItemsFilter()
        }
    }
    
    func getCategories(_ completion: @escaping () -> Void) {
        do {
            let request = Category.fetchRequest() as NSFetchRequest<Category>
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.categories = try context.fetch(request)
            
            for category in self.categories {
                let itemFilterOption = ItemFilter(
                    type: .category,
                    title: category.name,
                    predicate: NSPredicate(format: "categories CONTAINS %@", category),
                    image: UIImage(systemName: "tag")
                )
                itemFilterOptions.append(itemFilterOption)
            }
            
            completion()
        } catch {
            print("Error getting categories. \(error.localizedDescription)")
        }
    }
    
    func getCategoriesAsActions(action: CategoryAction) -> [UIAction] {
        var actions: [UIAction] = []
        
        for category in categories {
            let action = UIAction(title: category.name ?? "", image: UIImage(systemName: "tag")) { action in
                print("action: \(action)")
            }
            actions.append(action)
        }
        
        return actions
    }
    
    func getItems(searchStr: String? = nil) {
        print("getItems")
        
        do {
            let request = Item.fetchRequest() as NSFetchRequest<Item>
                        
            request.predicate = self.selectedItemFilter.predicate
            
//            if let searchStr {
//                var predicateSearch = NSPredicate(format: "name contains[c] '\(searchStr)'")
////                let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [predicateIsArchived, predicateSearch])
//                request.predicate = predicateSearch
//            }
            
            var sort = NSSortDescriptor(key: "createdDate", ascending: false)
            
            switch selectedSortType {
            case .title:
                sort = NSSortDescriptor(key: "name", ascending: true)
            case .newest:
                sort = NSSortDescriptor(key: "createdDate", ascending: false)
            case .oldest:
                sort = NSSortDescriptor(key: "createdDate", ascending: true)
            }
            
            if self.selectedItemFilter.type == .mostRecent {
                sort = NSSortDescriptor(key: "createdDate", ascending: false)
            }
            
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
            self.delegate?.didLoadItems()
        } catch {
            print("Error getting items. \(error.localizedDescription)")
        }
    }
    
    func addItem(name: String?, categories: String?, website: String?, price: String?, images: [UIImage]?) {
        let item = Item(context: self.context)
        
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
        
        self.saveContext()
    }
    
    func updateItem(item: Item, name: String?, categories: String?, website: String?, price: String?, image: UIImage?) {
        // TODO: updateItem
    }
    
    func addImages(item: Item, images: [UIImage]) {
        images.forEach { image in
            let itemImage = ItemImage(context: self.context)
            itemImage.image = image.jpegData(compressionQuality: 0.9)
            print("save image")
            item.addToImages(itemImage)
        }
    }
    
    func addCategories(_ item: Item, categories: [String]) {
        for categoryStr in categories {
            let category = Category(context: self.context)
            category.name = categoryStr
            item.addToCategories(category)
        }
    }
    
    func toggleItemCategory(_ item: Item, category: Category) {
        guard let itemCategories = item.categories else {
            return
        }
        
        if itemCategories.contains(category) {
            item.removeFromCategories(category)
        } else {
            item.addToCategories(category)
        }
        
        self.saveContext()
    }
    
    func addItemCategory(_ item: Item, categoryName: String) {
        let category = Category(context: self.context)
        category.name = categoryName
        item.addToCategories(category)
        self.saveContext()
    }
    
    func addItemCategory(_ item: Item, category: Category) {
        print("addItemCategory")
        item.addToCategories(category)
        self.saveContext()
    }
    
    func removeItemCategory(_ item: Item, category: Category) {
        print("removeItemCategory")
        item.removeFromCategories(category)
        self.saveContext()
    }
    
    func duplicateItem(_ item: Item) {
        // TODO: Duplicate item
    }
    
    func archiveItem(_ item: Item) {
        if item.isArchived == true {
            return
        }
        
        item.isArchived = true
        self.saveContext()
    }
    
    func unarchiveItem(_ item: Item) {
        if item.isArchived == false {
            return
        }
        
        item.isArchived = false
        self.saveContext()
    }
    
    func deleteItem(_ item: Item) {
        self.context.delete(item)
        self.saveContext()
    }
    
    func saveContext() {
        do {
            try self.context.save()
            delegate?.didSaveContext()
        } catch {
            print("Error saving context. \(error.localizedDescription)")
        }
    }
    
}
