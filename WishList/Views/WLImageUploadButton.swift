//
//  WLImageUploadButton.swift
//  WishList
//
//  Created by Marko Kos on 28.12.2022..
//

import UIKit
import SnapKit

class WLImageUploadButton: UIButton {
    
    let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isContextMenuInteractionEnabled = true
        showsMenuAsPrimaryAction = true
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    private func setupView() {
        self.showsMenuAsPrimaryAction = true
        self.backgroundColor = .black.withAlphaComponent(0.05)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.05).cgColor
        self.tintColor = .black.withAlphaComponent(0.3)
        
        iconView.image = UIImage(systemName: "plus.circle")
        
        self.addSubview(iconView)
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
}
