//
//  TestViewController.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import UIKit
import SnapKit

class TestViewController: UIViewController {
    
    let emptyState = WLEmptyStateView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(emptyState)
    }
    
    private func setupConstraints() {
        emptyState.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

}
