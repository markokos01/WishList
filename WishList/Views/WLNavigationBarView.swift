//
//  WLNavigationBarView.swift
//  WishList
//
//  Created by Marko Kos on 10.01.2023..
//

import UIKit
import SnapKit

class WLNavigationBarView: UIView {
    
    var title = "Title" {
        didSet {
            titleLabel.text = title.uppercased()
        }
    }
    
    private let titleLabel = UILabel()
    private let borderView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
 
    private func setupView() {
        titleLabel.text = title.uppercased()
        titleLabel.font = .rounded(ofSize: 14, weight: .semibold)
        
        borderView.backgroundColor = .black.withAlphaComponent(0.1)
        
        self.addSubview(titleLabel)
        self.addSubview(borderView)
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(53)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }

}
