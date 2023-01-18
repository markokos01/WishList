//
//  WishlistViewController.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import UIKit
import SnapKit

protocol WishlistViewControllerDelegate: AnyObject {
    func didTapNewAction()
    func didTapFilter(_ filter: ItemFilter)
}

class WishlistViewController: UIViewController {
    
    weak var delegate: WishlistViewControllerDelegate?
    
    var viewModel = WishlistViewModel()
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<WishlistSection, WishlistItem>!
    var snapshot: NSDiffableDataSourceSnapshot<WishlistSection, WishlistItem>!
    
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, WishlistItem> { (cell, indexPath, item) in
        
        // Define how data should be shown using content configuration
        var content = cell.defaultContentConfiguration()
        
        content.image = item.image
        
        content.text = item.title
        
        // Assign content configuration to cell
        cell.contentConfiguration = content
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
//    }
    
    private func setupView() {
//        title = "Wishlist"
        view.backgroundColor = .white
//        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        setupCollectionView()
        
        snapshot = NSDiffableDataSourceSnapshot<WishlistSection, WishlistItem>()
        
        snapshot.appendSections([.actions, .filters, .categories, .settings])
        snapshot.appendItems(viewModel.actionItems, toSection: .actions)
        snapshot.appendItems(viewModel.filterItems, toSection: .filters)
        snapshot.appendItems(viewModel.categoriesItems, toSection: .categories)
        snapshot.appendItems(viewModel.settingsItems, toSection: .settings)
        
        // Display data in the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
        
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.edges.equalTo(UIEdgeInsets(top: 26, left: 0, bottom: 0, right: 0))
        }
    }

}

extension WishlistViewController: UICollectionViewDelegate {
    func setupCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        config.showsSeparators = false
        
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            guard let item = dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            
            if item.canDelete == false {
                return nil
            }
            
            let editHandler: UIContextualAction.Handler = { action, view, completion in
                // TODO: Edit category
            }
            
            let editAction = UIContextualAction(style: .normal, title: nil, handler: editHandler)
            editAction.image = UIImage(systemName: "ellipsis")
            
            let deleteHandler: UIContextualAction.Handler = { action, view, completion in
                // TODO: Delete category
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: deleteHandler)
            deleteAction.image = UIImage(systemName: "trash")

            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(WLItemListCell.self, forCellWithReuseIdentifier: "itemCell")
        collectionView.backgroundColor = UIColor.white
        
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.allowsMultipleSelectionDuringEditing = true
        collectionView.backgroundColor = .white
        
        dataSource = UICollectionViewDiffableDataSource<WishlistSection, WishlistItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: WishlistItem) -> UICollectionViewCell? in
            
            // Dequeue reusable cell using cell registration (Reuse identifier no longer needed)
            let cell = collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration,
                                                                    for: indexPath,
                                                                    item: item)
            // Configure cell appearance
            
            cell.accessories = [.disclosureIndicator()]
            
//            if item.hasDisclosureIndicator {
//                cell.accessories = [.disclosureIndicator()]
//            } else {
//                let customAccessory = UICellAccessory.CustomViewConfiguration(
//                    customView: UIImageView(image: item.image),
//                    placement: .trailing(displayed: .always))
//                cell.accessories = [.customView(configuration: customAccessory)]
//            }
    
            return cell
        }
        
        collectionView.dataSource = dataSource
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = dataSource.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        
        switch selectedItem.actionType {
        case .newItem:
//            self.delegate?.didTapNewAction()
            self.dismiss(animated: true) {
                self.delegate?.didTapNewAction()
            }
//            self.navigationController?.pushViewController(NewItemViewController(), animated: true)
            
//
//            var viewControllers = self.navigationController!.viewControllers
//            viewControllers[viewControllers.count - 1] = NewItemViewController()
//            self.navigationController?.setViewControllers(viewControllers, animated: true)
        default:
            break
        }
        
        print(selectedItem)
    }
    
}
