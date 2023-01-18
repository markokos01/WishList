//
//  WLItemImageView.swift
//  WishList
//
//  Created by Marko Kos on 22.12.2022..
//

import UIKit
import SnapKit

class WLItemImageView: UIView {
    
    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    private func setupView() {
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        imageView.contentMode = .scaleAspectFill
        
        self.addSubview(imageView)
    }
    
    private func setupConstraints() {        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
