//
//  WLLabelWithIcon.swift
//  WishList
//
//  Created by Marko Kos on 28.12.2022..
//

import UIKit
import SnapKit

class WLLabelWithIcon: UIView {

    private let mainStackView = UIStackView()
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
 
    private func setupView() {
        mainStackView.axis = .horizontal
        mainStackView.spacing = 4
        
        label.font = .systemFont(ofSize: 11, weight: .medium)
        
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(label)
        
        self.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
//        imageView.snp.makeConstraints { make in
//            make.width.equalTo(14)
//            make.height.equalTo(14)
//        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
