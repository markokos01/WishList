//
//  WLItemListCell.swift
//  WishList
//
//  Created by Marko Kos on 22.12.2022..
//

import UIKit
import SnapKit

class WLItemListCell: UICollectionViewListCell {
    
    var item : Item? {
        didSet {
            guard let item else {
                return
            }

            if let name = item.name, !name.isEmpty {
                titleLabel.text = name
            } else {
                titleLabel.text = Item.defaultTitle
            }
            
            if let categoriesAsString = item.categoriesAsString {
                categoryView.isHidden = false
                categoryView.label.text = categoriesAsString
            } else {
                categoryView.isHidden = true
                categoryView.label.text = nil
            }
            
            if let website = item.website,
               item.categories?.count == 0 || website.isEmpty {
                subtitleSeparatorView.isHidden = true
            } else {
                subtitleSeparatorView.isHidden = false
            }
            
            if let website = item.website,
               website.isEmpty {
                websiteView.isHidden = true
                websiteView.label.text = nil
            } else {
                websiteView.isHidden = false
                websiteView.label.text = item.website
            }
            
            if !item.isPriceZero, let price = item.price, let localeIdentifier = item.localeIdentifier {
                let locale = Locale.init(identifier: localeIdentifier)
                priceLabel.text = price.description(withLocale: locale)
            } else {
                priceLabel.text = nil
            }
            
            if let image = item.firstItemImage?.image {
                itemImageView.image = UIImage(data: image)
            } else {
                itemImageView.image = Item.defaultImage
                itemImageView.layer.borderColor = UIColor.clear.cgColor
            }
            
        }
    }
    
    let mainStackView = UIStackView()
    let itemImageView = WLItemImageView()
    let contentStackView = UIStackView()
    let titleLabel = UILabel()
    let subtitleStackView = UIStackView()
    let subtitleSeparatorView = UIView()
    let categoryView = WLLabelWithIcon()
    let websiteView = WLLabelWithIcon()
    let priceLabel = UILabel()
    let separatorView = UIView()
    
    override func updateConstraints() {
        super.updateConstraints()

        separatorLayoutGuide.leadingAnchor.constraint(equalTo: itemImageView.leadingAnchor, constant: 106).isActive = true
        separatorLayoutGuide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.accessories = [.multiselect(displayed: .whenEditing)]

        mainStackView.axis = .horizontal
        mainStackView.alignment = .leading
        mainStackView.distribution = .fill
        mainStackView.spacing = 16
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .leading
        contentStackView.distribution = .fill
        contentStackView.spacing = 6
         
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2
                
        subtitleStackView.axis = .horizontal
        subtitleStackView.spacing = 4
        subtitleStackView.distribution = .fillProportionally
        subtitleStackView.alignment = .center
    
        categoryView.label.text = "Tags"
        categoryView.imageView.image = UIImage(systemName: "tag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .small))?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        subtitleSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        subtitleSeparatorView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        websiteView.label.text = "Website"
        websiteView.imageView.image = UIImage(systemName: "book.closed", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .small))?.withTintColor(.black, renderingMode: .alwaysOriginal)
        
        subtitleStackView.addArrangedSubview(categoryView)
        subtitleStackView.addArrangedSubview(subtitleSeparatorView)
        subtitleStackView.addArrangedSubview(websiteView)
        
        priceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        priceLabel.textColor = .lightGray
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleStackView)
        contentStackView.addArrangedSubview(priceLabel)
        
        mainStackView.addArrangedSubview(itemImageView)
        mainStackView.addArrangedSubview(contentStackView)
        
        
        contentView.addSubview(mainStackView)
    }
    
    private func setupConstraints() {
        subtitleSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(12).priority(.high)
            make.width.equalTo(1)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }
        
        itemImageView.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90).priority(.high)
        }
    }

}
