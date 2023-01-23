//
//  HomeViewModel.swift
//  WishList
//
//  Created by Marko Kos on 28.12.2022..
//

import Foundation
import UIKit
import CoreData
import Combine

protocol ItemsViewModelDelegate: AnyObject {
    func didLoadItems()
    func didLoadCategories()
}

class HomeViewModel {
        
    // MARK: - Delegate
    
    weak var delegate: ItemsViewModelDelegate?
        
    // MARK: - Repositories
    
    private let itemRepository = ItemCoreDataRepository()
    private let categoryDataSource = CategoryCoreDataRepository()
    
    // MARK: - Data
    
    var items: [Item] = []
    var categories: [Category] = []
    
    func getItems(searchStr: String? = nil) {
        var sortType: ItemSortType = selectedSortType
        
        if selectedItemFilter?.type == .mostRecent {
            sortType = .newest
        }
        
        let predicate = self.selectedItemFilter?.predicate
        
        self.items = itemRepository.getAll(search: nil, predicate: predicate, sortType: sortType)
        self.delegate?.didLoadItems()
    }
    
    func getCategories() {
        self.categories = self.categoryDataSource.getAll()
        self.buildCategoryFilters()
        self.delegate?.didLoadCategories()
    }
    
    @Published var title: String?
    
    // MARK: - Search
    
    var searchBarPlaceholder = "Search"
    var extendedSearchBarPlaceholder: String {
        if let title = selectedItemFilter?.title {
            return "Search in '\(title)'"
        } else {
            return "Search"
        }
    }
    
    // MARK: - Filtering
    
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
    
    @Published var selectedItemFilter: ItemFilter?
    
    func filterBy(_ filter: ItemFilter, completion: @escaping(String?) -> Void) {
        self.selectedItemFilter = filter
        self.getItems()
        completion(filter.title)
    }
    
    func buildCategoryFilters() {
        for category in self.categories {
            let itemFilterOption = ItemFilter(
                type: .category,
                title: category.name,
                predicate: NSPredicate(format: "categories CONTAINS %@", category),
                image: UIImage(systemName: "tag")
            )
            itemFilterOptions.append(itemFilterOption)
        }
    }
    
    // MARK: - Sorting
    
    @Published var selectedSortType: ItemSortType = .newest
    
    var isSortEnabled: Bool {
        return self.selectedItemFilter?.type != .mostRecent
    }
    
    var sortButtonTitle: String {
        return "\(self.items.count) items"
    }
    
    func sortBy(_ sortType: ItemSortType) {
        self.selectedSortType = sortType
        self.getItems()
    }
    
    // MARK: - Editing
    
    @Published var isEditing = false
    
    @Published var selectedItemsCount = 0
    
    func selectItem(count: Int) {
        selectedItemsCount = count
    }
    
    func deselectItem(count: Int) {
        selectedItemsCount = count
    }
        
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        selectedItemFilter = itemFilterOptions.first!
        
        Publishers.CombineLatest3($selectedItemFilter, $isEditing, $selectedItemsCount)
            .sink(receiveValue: { (filter, editing, count) in
                self.title = filter?.title

                if editing {
                    if count > 0 {
                        self.title = "\(count) items"
                    } else {
                        self.title = "Select items"
                    }
                }
            })
            .store(in: &cancellables)
    }
    

    func toggleItemCategory(_ item: Item, category: Category) {
        self.itemRepository.toggleCategory(item, category: category)
        self.getItems()
    }
    
    func addItemCategory(_ item: Item, categoryName: String) {
        self.itemRepository.addCategory(item, categoryName: categoryName)
    }
    
    func addItemCategory(_ item: Item, category: Category) {
        self.itemRepository.addCategory(item, category: category)
    }
    
    func removeItemCategory(_ item: Item, category: Category) {
        self.itemRepository.removeCategory(item, category: category)
    }
    
    func duplicateItem(_ item: Item) {
        self.itemRepository.duplicate(item)
    }
    
    func archiveItem(_ item: Item) {
        self.itemRepository.archive(item)
        self.getItems()
    }
    
    func unarchiveItem(_ item: Item) {
        self.itemRepository.unarchive(item)
        self.getItems()
    }
    
    func deleteItem(_ item: Item) -> Result<Bool, Error> {
        let result = self.itemRepository.delete(item)
        switch result {
        case .success(_):
            self.getItems()
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
    
}

// MARK: - User Interaction

extension HomeViewModel {
    
    enum UserInput {
        case archiveItem
    }
    
    func onUserInput(_ input: UserInput, item: Item?) {
        switch input {
        case .archiveItem:
            guard let item else {
                return
            }
            
            self.itemRepository.archive(item)
        }
    }
    
}
