//
//  CoreDataManager.swift
//  WishList
//
//  Created by Marko Kos on 18.01.2023..
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Item] = []
    var categories: [Category] = []
    
    func getCategories() {
        do {
            let request = Category.fetchRequest() as NSFetchRequest<Category>
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.categories = try context.fetch(request)
        } catch {
            print("Error getting categories. \(error.localizedDescription)")
        }
    }
    
    func getItems(searchStr: String? = nil) {
        print("getItems")
        
        do {
            let request = Item.fetchRequest() as NSFetchRequest<Item>
            
            let sort = NSSortDescriptor(key: "createdDate", ascending: false)
            request.sortDescriptors = [sort]
            
            self.items = try context.fetch(request)
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
        } catch {
            print("Error saving context. \(error.localizedDescription)")
        }
    }
    
}
