//
//  NewItemCategoryViewController.swift
//  WishList
//
//  Created by Marko Kos on 09.01.2023..
//

import UIKit
import SnapKit

protocol NewItemCategoryViewControllerDelegate: AnyObject {
    func didSaveCategory()
}

class NewItemCategoryViewController: UIViewController {
    
    var item: Item?
    let viewModel = ItemsViewModel()
    weak var delegate: NewItemViewControllerDelegate?
    
    private let customNavigationBar: WLNavigationBarView = {
        let navigationBar = WLNavigationBarView()
        navigationBar.title = "New category"
        return navigationBar
    }()

    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Title"
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let footerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Cancel".uppercased()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }
        config.cornerStyle = .large
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Save".uppercased()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }
        config.cornerStyle = .large
        let button = UIButton(configuration: config)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("item: \(item)")
        
        categoryTextField.delegate = self
        saveButton.isEnabled = false
        
        updateUI()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        categoryTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func updateUI() {
        self.view.backgroundColor = .white
        self.isModalInPresentation = true
        
        footerStackView.addArrangedSubview(cancelButton)
        footerStackView.addArrangedSubview(saveButton)
        
        view.addSubview(customNavigationBar)
        view.addSubview(categoryTextField)
        view.addSubview(footerStackView)
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
        }
        
        categoryTextField.snp.makeConstraints { make in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(34)
//            make.bottom.lessThanOrEqualTo(footerStackView.snp.top)
        }
    
        footerStackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
    }
    
    @objc func didTapCancelButton() {
        closeView()
    }
    
    @objc func didTapSaveButton() {
        guard let item = item,
              let categoryText = categoryTextField.text else {
            return
        }
                
        self.viewModel.addItemCategory(item, categoryName: categoryText)
        self.delegate?.didSave()
        closeView()
    }
    
    func closeView() {
        categoryTextField.resignFirstResponder()
        self.dismiss(animated: true)
    }

}

extension NewItemCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        guard let oldText = categoryTextField.text else {
            return false
        }
        
        let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
        saveButton.isEnabled = !newText.isEmpty
        return true
    }
}
