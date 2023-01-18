//
//  WLEmptyStateView.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import UIKit
import SnapKit

class WLEmptyStateView: UIView {
    
    let stackView = UIStackView()
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
 
    private func setupView() {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
       
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
        imageView.tintColor = .black.withAlphaComponent(0.2)
        
        titleLabel.text = "Title"
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .black.withAlphaComponent(0.4)
        
        subtitleLabel.text = "Subtitle"
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        subtitleLabel.textColor = .black.withAlphaComponent(0.6)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        stackView.setCustomSpacing(0, after: titleLabel)
        
        self.addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
