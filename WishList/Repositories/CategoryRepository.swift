//
//  CategoryRepository.swift
//  WishList
//
//  Created by Marko Kos on 18.01.2023..
//

import Foundation
import CoreData
import Combine

protocol CategoryRepositoryInterface {
    func getAll() -> [Category]
    func create(name: String)
}

class CategoryCoreDataRepository: CategoryRepositoryInterface {
    
    let manager = CoreDataManager.shared
    let context = CoreDataManager.shared.context
    
    func getAll() -> [Category] {
        do {
            let request = Category.fetchRequest() as NSFetchRequest<Category>
            return try context.fetch(request)
        } catch {
            print("getCategories error")
            return []
        }
    }
    
    func create(name: String) {
        let category = Category(context: context)
        
        category.name = name
        
        do {
            try context.save()
        } catch {
            print("create error")
            
        }
    }
    
}
