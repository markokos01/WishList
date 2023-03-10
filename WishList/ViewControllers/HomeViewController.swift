//
//  HomeViewController.swift
//  WishList
//
//  Created by Marko Kos on 22.12.2022..
//

import UIKit
import SnapKit
import CoreData
import Combine

class HomeViewController: UIViewController, ItemsViewModelDelegate {
    
    let viewModel = HomeViewModel()
    
    let searchController = UISearchController()
    var collectionView: UICollectionView!
    var editButton = WLEditButton()
    
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        setupView()
        setupConstraints()
                
        fetchItems()
        fetchCategories()
        
        viewModel.$title.assign(to: \.title, on: self).store(in: &cancellables)

//        viewModel.$title
//            .sink(receiveValue: { title in
//                print("did receive title: \(title)")
//                self.title = title
//            })
//            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.white
        
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        setupEditButton()
                
        view.addSubview(collectionView)
        view.addSubview(editButton)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        editButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if self.viewModel.items.isEmpty {
                let image = self.viewModel.selectedItemFilter?.image
                let subtitle = self.viewModel.selectedItemFilter?.title
                // TODO: Proslijediti odabrani filter
                self.collectionView.showEmptyState(image: image, title: "No items in", subtitle: subtitle)
            } else {
                self.collectionView.hideEmptyState()
            }
            
            self.editButton.mainButton.configuration?.title = self.viewModel.sortButtonTitle
            
            // TODO: Ne pozivati reloadData pri dodavanju ili brisanju retka
            self.collectionView.reloadData()
        }
    }

}

// MARK: - Data

extension HomeViewController {
    func fetchItems(searchStr: String? = nil) {
        viewModel.getItems(searchStr: searchStr)
    }
    
    func fetchCategories() {
        viewModel.getCategories()
    }
    
    func didLoadItems() {
        updateUI()
    }
    
    func didLoadCategories() {
        setupNavigationRightMenu()
    }
}

// MARK: - Navigation

extension HomeViewController {
    
    func goToAddItem() {
        let newItemVC = NewItemViewController()
        newItemVC.delegate = self
        let navigationController = UINavigationController(rootViewController: newItemVC)
        self.present(navigationController, animated: true)
    }
    
    func goToEditItem(_ item: Item) {
        let newItemVC = NewItemViewController()
        newItemVC.item = item
        newItemVC.delegate = self
        let navigationController = UINavigationController(rootViewController: newItemVC)
        self.present(navigationController, animated: true)
    }
    
    func goToItemDetails(_ item: Item) {
        let itemDetailsVC = ItemDetailsViewController()
        itemDetailsVC.item = item
        self.navigationController?.pushViewController(itemDetailsVC, animated: true)
    }
    
}

// MARK: - Navigation Bar

extension HomeViewController {
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupNavigationRightMenu() {
        DispatchQueue.main.async {
            let newItemAction = UIAction(title: "New item", image: UIImage(systemName: "plus.circle")) { (_) in
                self.goToAddItem()
            }
            let newItemMenu = UIMenu(options: .displayInline, children: [newItemAction])
            
            var actions: [UIAction] = []
            
            for itemFilter in self.viewModel.itemFilterOptions {
                let action = UIAction(title: itemFilter.title ?? "", image: itemFilter.image) { (_) in
                    self.viewModel.filterBy(itemFilter) { title in
//                        self.title = title
                        self.editButton.mainButton.menu = self.createSortMenu()
                    }
                }
                actions.append(action)
            }
            
            let filtersMenu = UIMenu(options: .displayInline, children: actions)
            
            let menu = UIMenu(options: .displayInline, children: [
                newItemMenu,
                filtersMenu,
            ])
            
            let custom = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: nil)
            custom.menu = menu
            
            self.navigationItem.rightBarButtonItem = custom
        }
    }
    
}

// MARK: - Edit Button

extension HomeViewController: CustomEditButtonDelegate {
    
    func setupEditButton() {
        editButton.delegate = self
        editButton.mainButton.showsMenuAsPrimaryAction = true
        editButton.mainButton.preferredMenuElementOrder = .fixed
        editButton.mainButton.menu = createSortMenu()
    }
    
    func createSortMenu() -> UIMenu {
        let sortByTitleAction = UIAction(title: "Title", image: UIImage(systemName: "square.stack.3d.up.badge.a"), state: self.viewModel.selectedSortType == .title ? .on : .off) {action in
            self.sortByHandler(.title)
        }
        
        let sortByNewestAction = UIAction(title: "Newest", image: UIImage(systemName: "square.stack.3d.up.fill"), state: self.viewModel.selectedSortType == .newest ? .on : .off) { action in
            self.sortByHandler(.newest)
        }
        
        let sortByOldestAction = UIAction(title: "Oldest", image: UIImage(systemName: "square.stack.3d.up"), state: self.viewModel.selectedSortType == .oldest ? .on : .off) {action in
            self.sortByHandler(.title)
        }
        
        let sortByMenu = UIMenu(title: "SORT BY...", options: .displayInline, children: [sortByTitleAction, sortByNewestAction, sortByOldestAction])
        
        let editAction = UIAction(title: "Edit...", image: UIImage(systemName: "list.bullet")) { action in
            self.editHandler()
        }
        
        let editMenu = UIMenu(title: "", options: .displayInline, children: [editAction])
        
        let searchAction = UIAction(title: "Search...", image: UIImage(systemName: "magnifyingglass")) { action in
            self.searchHandler()
        }
        
        let searchMenu = UIMenu(title: "", options: .displayInline, children: [searchAction])
        
        var children: [UIMenuElement] = []
        if self.viewModel.isSortEnabled {
            children = [sortByMenu, editMenu, searchMenu]
        } else {
            children = [editMenu, searchMenu]
        }
        
        return UIMenu(title: "", children: children)
    }
    
    func sortByHandler(_ sortType: ItemSortType) {
        self.viewModel.sortBy(sortType)
        self.editButton.mainButton.menu = self.createSortMenu()
    }
    
    func editHandler() {
        self.setEditing(!self.isEditing, animated: true)
        self.editButton.isEditing = self.isEditing
    }
    
    func searchHandler() {
        self.searchController.isActive = true
        self.searchController.searchBar.becomeFirstResponder()
        self.editButton.isHidden = true
    }
    
    func didTapSelectAllButton(_ button: WLEditButton) {
        let totalRows = self.collectionView.numberOfItems(inSection: 0)
        
        for row in 0..<totalRows {
            self.collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: [])
        }
    }
    
    func didTapCancelButton(_ button: WLEditButton) {
        self.setEditing(false, animated: true)
    }
    
}

// MARK: - Handlers

extension HomeViewController {
    
}

// MARK: - Actions

extension HomeViewController: NewItemCategoryViewControllerDelegate {
    
    @objc func addTapped() {
        goToAddItem()
    }
    
    @objc func newItemCategoryTapped(item: Item) {
        let newItemCategoryVC = NewItemCategoryViewController()
        newItemCategoryVC.item = item
        newItemCategoryVC.delegate = self
        let nav = UINavigationController(rootViewController: newItemCategoryVC)
        nav.modalPresentationStyle = .pageSheet

        let smallId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
            return 190
        }
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [smallDetent]
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 10
        }

        self.present(nav, animated: true, completion: nil)
    }
    
    func didSaveCategory() {
        self.fetchItems()
        self.fetchCategories()
    }
    
}

// MARK: - NewItemViewControllerDelegate

extension HomeViewController: NewItemViewControllerDelegate {
    func didSave() {
        self.fetchItems()
    }
}

// MARK: - Search

extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        let directionalMargins = NSDirectionalEdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40)
        searchController.searchBar.directionalLayoutMargins = directionalMargins
        searchController.searchBar.placeholder = self.viewModel.searchBarPlaceholder
        searchController.hidesNavigationBarDuringPresentation = true
        
        searchController.searchBar.delegate = self
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.placeholder = self.viewModel.extendedSearchBarPlaceholder
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.placeholder = self.viewModel.searchBarPlaceholder
        return true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        if text.isEmpty {
            fetchItems()
            return
        }
        
        fetchItems(searchStr: text)
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.editButton.isHidden = false
    }
    
}

// MARK: - CollectionView

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func setupCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        
        config.leadingSwipeActionsConfigurationProvider = { indexPath in
            let item = self.viewModel.items[indexPath.row]
            
            let archiveHandler: UIContextualAction.Handler = { action, view, completion in
                self.viewModel.archiveItem(item)
                completion(true)
                // TODO: Vidjeti jel treba tu obrisati taj redak
//                self.collectionView.reloadItems(at: [indexPath])
            }
            
            let unarchiveHandler: UIContextualAction.Handler = { action, view, completion in
                self.viewModel.unarchiveItem(item)
                completion(true)
                // TODO: Vidjeti jel treba tu obrisati taj redak
//                self.collectionView.deleteItems(at: [indexPath])
            }
            
            let handler = item.isArchived ? unarchiveHandler : archiveHandler
            let action = UIContextualAction(style: .normal, title: nil, handler: handler)
            let image = item.isArchived ? UIImage(systemName: "tray.and.arrow.up") : UIImage(systemName: "archivebox")
            action.image = image
            
            return UISwipeActionsConfiguration(actions: [action])
        }

        config.trailingSwipeActionsConfigurationProvider = { indexPath in
            let item = self.viewModel.items[indexPath.row]

            let deleteHandler: UIContextualAction.Handler = { action, view, completion in
                self.viewModel.deleteItem(item)
                completion(true)
                // TODO: Jel treba tu deleteItems?
                self.collectionView.deleteItems(at: [indexPath])
//                self.fetchItems()
            }

            let action = UIContextualAction(style: .destructive, title: nil, handler: deleteHandler)
            action.image = UIImage(systemName: "trash")

            return UISwipeActionsConfiguration(actions: [action])
        }

        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(WLItemListCell.self, forCellWithReuseIdentifier: "itemCell")
        collectionView.backgroundColor = UIColor.white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelectionDuringEditing = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.items.count
    }
    
    func getCategoriesAsAddActions(item: Item, indexPaths: [IndexPath]) -> [UIMenu] {
        // TOOD: Ne osvje??i se menu nakon dodavanja nove kategorije i dohvata svih kategorija
        var menus: [UIMenu] = []
        
        let newCategoryAction = UIAction(title: "New Category...", image: UIImage(systemName: "plus.circle")) { action in
            self.newItemCategoryTapped(item: item)
        }
        
        let addCategoryMenu = UIMenu(title: "", options: .displayInline, children: [newCategoryAction])
        
        menus.append(addCategoryMenu)
        
        var categoryActions: [UIAction] = []
        for category in self.viewModel.categories {
            guard let itemCategories = item.categories else {
                return []
            }

            var state: UIMenuElement.State = .off
            
            let itemContainsCategory = itemCategories.contains(category)
            if itemContainsCategory {
                state = .on
            }
            
            let action = UIAction(title: category.name ?? "", image: UIImage(systemName: "tag"), state: state) { action in
                self.viewModel.toggleItemCategory(item, category: category)
//                self.collectionView.reloadItems(at: indexPaths)
            }
            categoryActions.append(action)
        }
        
        let categoriesMenu = UIMenu(title: "", options: .displayInline, children: categoryActions)
        menus.append(categoriesMenu)
        
        return menus
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPaths.isEmpty {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions -> UIMenu? in
            // TODO: Napraviti da se ne otvara contextmenu ako nema ni??ta u lisit, ovako trenutno puca app
            let item = self.viewModel.items[indexPaths[0].row]
            
            let archiveAction = UIAction(title: "Archive", image: UIImage(systemName: "archivebox")) { action in
                self.viewModel.archiveItem(item)
            }
            
            let categoriesActions = self.getCategoriesAsAddActions(item: item, indexPaths: indexPaths)
                        
            let categoriesMenu = UIMenu(title: "Categories...", image: UIImage(systemName: "tag"), children: categoriesActions)
            
            /// Share Menu
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, discoverabilityTitle: nil) { action in
            }
            let openInBrowserAction = UIAction(title: "Open in Browser", image: UIImage(systemName: "safari"), identifier: nil, discoverabilityTitle: nil) { action in
            }
            let shareMenu = UIMenu(title: "", options: .displayInline, children: [shareAction, openInBrowserAction])
            
            /// Duplicate Menu
            let duplicateAction = UIAction(title: "Duplicate...", image: UIImage(systemName: "plus.square.on.square"), identifier: nil, discoverabilityTitle: nil) { action in
                self.goToEditItem(item)
            }
            let duplicateMenu = UIMenu(title: "", options: .displayInline, children: [duplicateAction])
            
            /// Delete Menu
            let deleteAction = UIAction(title: "Delete...", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { action in
                self.viewModel.deleteItem(item)
            }
            let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])
            
            return UIMenu(image: nil, identifier: nil, options: [], children: [archiveAction, categoriesMenu, shareMenu, duplicateMenu, deleteMenu])
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.viewModel.items[indexPath.row]
        
        let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! WLItemListCell
        itemCell.item = item
        return itemCell
    }
    
}

// MARK: - Editing

extension HomeViewController {
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.collectionView.isEditing = editing
        self.viewModel.isEditing = editing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCellsCount = self.collectionView.indexPathsForSelectedItems!.count
        self.viewModel.selectItem(count: selectedCellsCount)
        
        if self.isEditing {
            return
        }
        
        print("didSelectItemAt")
        let item = self.viewModel.items[indexPath.row]
        self.goToItemDetails(item)
        self.collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let selectedCellsCount = self.collectionView.indexPathsForSelectedItems!.count
        self.viewModel.selectItem(count: selectedCellsCount)
    }
    
}
