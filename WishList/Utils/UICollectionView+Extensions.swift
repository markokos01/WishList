//
//  UICollectionView+Extensions.swift
//  WishList
//
//  Created by Marko Kos on 05.01.2023..
//

import Foundation
import UIKit

extension UICollectionView {

    func showEmptyState(image: UIImage?, title: String?, subtitle: String?) {
        let emptyState = WLEmptyStateView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyState.imageView.image = image
        emptyState.titleLabel.text = title
        emptyState.subtitleLabel.text = subtitle

        self.backgroundView = emptyState
    }

    func hideEmptyState() {
        self.backgroundView = nil
    }
    
}
