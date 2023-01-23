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
    
    static let shared = CoreDataManager()
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveContext() {
        do {
            try self.context.save()
        } catch {
            print("Error saving context. \(error.localizedDescription)")
        }
    }
    
}
