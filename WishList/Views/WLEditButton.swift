//
//  WLEditButton.swift
//  WishList
//
//  Created by Marko Kos on 11.01.2023..
//

import UIKit
import SnapKit

// TODO: Napraviti da se animira od donjeg ruba a ne od centra. Manji gumb bi se trebao povlačiti prema gore kada se povećava visina.
             
protocol CustomEditButtonDelegate: AnyObject {
//    func didTapMainButton()
    func didTapSelectAllButton(_ button: WLEditButton)
//    func didTapTagButton()
//    func didTapDeleteButton()
    func didTapCancelButton(_ button: WLEditButton)
}
   
class WLEditButton: UIView {
    
    weak var delegate: CustomEditButtonDelegate?
    
    var isEditing = false {
        didSet {
            if isEditing {
                self.editButtonStack.alpha = 0
                self.editButtonStack.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                UIView.animate(withDuration: 0.2) {
                    self.mainButton.alpha = 0
                    
                    self.editButtonStack.isHidden = false
                    self.editButtonStack.transform = .identity
                    self.editButtonStack.alpha = 1
                    self.editButtonStack.snp.remakeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    self.layoutIfNeeded()
                }
            } else {
                self.mainButton.alpha = 0
                self.editButtonStack.transform = .identity
                
                UIView.animate(withDuration: 0.3) {
                    self.mainButton.alpha = 1
                    
                    self.editButtonStack.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.editButtonStack.alpha = 0
                    self.editButtonStack.snp.remakeConstraints { make in
                        make.center.equalToSuperview()
                    }
                    
                    self.layoutIfNeeded()
                }
            }
        }
    }

    var mainButton = UIButton()
    
    var editButtonStack = UIStackView()
    var selectAllButton = UIButton()
    var tagButton = UIButton()
    var deleteButton = UIButton()
    var cancelButton = UIButton()
    var separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isEditing {
            let height = bounds.height
            layer.cornerRadius = height / 2
        } else {
            layer.cornerRadius = 10
        }
    }
 
    private func setupView() {
        self.backgroundColor = .black.withAlphaComponent(0.04)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.06).cgColor
        self.clipsToBounds = true
    
        setupMainButton()
        setupEditButtonStack()
        
        editButtonStack.isHidden = true
        
        self.addSubview(mainButton)
        self.addSubview(editButtonStack)
    }
    
    private func setupConstraints() {
        mainButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        editButtonStack.snp.makeConstraints { make in
            make.center.equalToSuperview()            
        }
    }
    
    private func setupMainButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold))
        config.title = "10 items"
        config.buttonSize = .mini
        config.imagePlacement = .trailing
        config.cornerStyle = .capsule
        config.imagePadding = 4
        config.baseForegroundColor = .gray
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 14, weight: .medium)
            return outgoing
        }
        mainButton = UIButton(configuration: config, primaryAction: UIAction(handler: { (action) in
            print("mainButton tap")
        }))
    }
    
    private func setupEditButtonStack() {
        setupSelectAllButton()
        setupTagButton()
        setupDeleteButton()
        setupCancelButton()
        
        editButtonStack.axis = .horizontal
        editButtonStack.spacing = 8
        editButtonStack.isLayoutMarginsRelativeArrangement = true
        editButtonStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        separatorView.backgroundColor = .black.withAlphaComponent(0.2)
        separatorView.snp.makeConstraints { make in
            make.width.equalTo(1)
        }
        
        editButtonStack.addArrangedSubview(selectAllButton)
        editButtonStack.addArrangedSubview(tagButton)
        editButtonStack.addArrangedSubview(deleteButton)
        editButtonStack.addArrangedSubview(separatorView)
        editButtonStack.addArrangedSubview(cancelButton)
    }
    
    private func setupSelectAllButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "checklist.checked", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config.buttonSize = .small
        config.imagePlacement = .trailing
        selectAllButton = UIButton(configuration: config, primaryAction: UIAction(handler: {(action) in
            self.delegate?.didTapSelectAllButton(self)
        }))
    }
    
    private func setupTagButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "tag", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config.buttonSize = .small
        config.imagePlacement = .trailing
        tagButton = UIButton(configuration: config, primaryAction: UIAction(handler: {(action) in
            // TODO: Show tags UIMenu
        }))
    }
    
    private func setupDeleteButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "trash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        config.buttonSize = .small
        config.imagePlacement = .trailing
        deleteButton = UIButton(configuration: config, primaryAction: UIAction(handler: {(action) in
            // TODO: Delete selected rows
        }))
    }
    
    private func setupCancelButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Cancel"
        config.attributedTitle = AttributedString("Cancel", attributes: AttributeContainer([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold)]))
        config.buttonSize = .small
        config.imagePlacement = .trailing
        cancelButton = UIButton(configuration: config, primaryAction: UIAction(handler: { (action) in
            print("cancelButton tap")
            self.isEditing = false
            self.delegate?.didTapCancelButton(self)
        }))
    }

}
