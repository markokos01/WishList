//
//  NewItemViewController.swift
//  WishList
//
//  Created by Marko Kos on 22.12.2022..
//

import UIKit
import SnapKit
import Photos
import PhotosUI

protocol NewItemViewControllerDelegate: AnyObject {
    func didSave()
}

class NewItemViewController: UIViewController, UINavigationControllerDelegate {
    
    let viewModel = NewItemViewModel()
    
    var item: Item?
    var images: [UIImage] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let scrollView = UIScrollView()
    let mainStackView = UIStackView()
    
    let horizontalScrollView = UIScrollView()
    let formStackView = UIStackView()
    let nameTextField = UITextField()
    let categoryTextField = UITextField()
    let websiteTextField = UITextField()
    let priceTextField = UITextField()
    let imageUploadButton = WLImageUploadButton()
    
    let imageStackView = UIStackView()
        
    weak var delegate: NewItemViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func updateUI() {
        view.backgroundColor = UIColor.white
        title = (item != nil) ? "Edit item" : "New item"
        
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = save
        
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.alignment = .fill
        mainStackView.spacing = 16
//        mainStackView.isLayoutMarginsRelativeArrangement = true
//        mainStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        
        nameTextField.placeholder = "Name"
        nameTextField.text = item?.name
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        nameTextField.autocorrectionType = .no
        
        
        
        categoryTextField.placeholder = "Category"
        if let categories = item?.categories as? Set<Category> {
            categoryTextField.text = categories.map { $0.name ?? "" }.lazy.joined(separator: ", ")
        }
        categoryTextField.layer.borderWidth = 1
        categoryTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        categoryTextField.autocorrectionType = .no
        
        websiteTextField.placeholder = "Website"
        websiteTextField.text = item?.website
        websiteTextField.layer.borderWidth = 1
        websiteTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        websiteTextField.autocorrectionType = .no
        websiteTextField.autocapitalizationType = .none
        
        priceTextField.placeholder = "Price"
        priceTextField.text = item?.price?.description(withLocale: Locale.current)
        priceTextField.layer.borderWidth = 1
        priceTextField.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        priceTextField.autocorrectionType = .no
        priceTextField.keyboardType = .decimalPad
        
        
        imageStackView.axis = .horizontal
        imageStackView.distribution = .equalSpacing
        imageStackView.alignment = .leading
        imageStackView.isLayoutMarginsRelativeArrangement = true
//        imageStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        imageStackView.spacing = 16
        
        let cameraAction = UIAction(title: "Camera", image: UIImage(systemName: "camera")) { action in
            self.openCamera()
        }
        
        let photoLibraryAction = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle.angled")) { action in
            self.openPHPicker()
        }
        
        let filesAction = UIAction(title: "Files", image: UIImage(systemName: "folder")) { action in
            self.openDocumentPicker()
        }
        
        imageUploadButton.menu = UIMenu(title: "Add from...", options: .displayInline, children: [cameraAction, photoLibraryAction, filesAction])
        imageUploadButton.showsMenuAsPrimaryAction = true
        

//        imageStackView.addArrangedSubview(imageView)
        imageStackView.addArrangedSubview(imageUploadButton)
        
        formStackView.axis = .vertical
        formStackView.alignment = .fill
        formStackView.distribution = .fill
        formStackView.spacing = 16
        formStackView.isLayoutMarginsRelativeArrangement = true
        formStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        horizontalScrollView.addSubview(imageStackView)
     
        mainStackView.addArrangedSubview(horizontalScrollView)
//        formStackView.addArrangedSubview(imageUploadButton)
        formStackView.addArrangedSubview(nameTextField)
        formStackView.addArrangedSubview(categoryTextField)
        formStackView.addArrangedSubview(websiteTextField)
        formStackView.addArrangedSubview(priceTextField)
        
        mainStackView.addArrangedSubview(formStackView)
        

        scrollView.addSubview(mainStackView)
        
        view.addSubview(scrollView)
        
        horizontalScrollView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(112)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        imageStackView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.width.equalTo(scrollView)
            make.edges.equalTo(scrollView)
        }
    }
    
    @objc func saveTapped() {
        if let existingItem = item {
            viewModel.updateItem(item: existingItem, name: nameTextField.text, categories: categoryTextField.text, website: websiteTextField.text, price: priceTextField.text, image: nil)
        } else {            
            viewModel.addItem(name: nameTextField.text, categories: categoryTextField.text, website: websiteTextField.text, price: priceTextField.text, images: images)
        }
        
        delegate?.didSave()
        self.dismiss(animated: true)
    }

}

// MARK: - Camera

extension NewItemViewController: UIImagePickerControllerDelegate {
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
//        imagePicker.allowsEditing = true
        imagePicker.showsCameraControls = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        var newImage: UIImage

        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }

        let itemImageView = WLItemImageView()
        itemImageView.image = newImage
        itemImageView.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
        }
        
        imageStackView.addArrangedSubview(itemImageView)
        
        dismiss(animated: true)
    }
}

// MARK: - Photo Library

extension NewItemViewController: PHPickerViewControllerDelegate {
    func openPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images

        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = self
        present(controller, animated: true)
    }
    
    func imageHandler(_ image: UIImage) {
        DispatchQueue.main.async {
            print("Selected image: \(image)")
            self.images.append(image)
             
             let itemImageView = WLItemImageView()
             itemImageView.image = image
             itemImageView.snp.makeConstraints { make in
                 make.width.equalTo(90)
                 make.height.equalTo(90)
             }
             
             itemImageView.isHidden = true
             UIView.animate(withDuration: 0.3) {
                 itemImageView.isHidden = false
    //                        self.imageStackView.addArrangedSubview(itemImageView)
                 self.imageStackView.insertArrangedSubview(itemImageView, at: 0)
             }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        /// https://stackoverflow.com/questions/68255880/how-to-get-webp-images-from-gallery-with-phpicker
        picker.dismiss(animated: true, completion: nil)
        // TODO: Vidjeti zašto se dismissa i cijeli viewcontroller
        for itemProvider in results.map({$0.itemProvider}) {
            if itemProvider.hasItemConformingToTypeIdentifier(UTType.webP.identifier) {
                itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) {data, err in
                    if let data = data, let img = UIImage.init(data: data) {
                        self.imageHandler(img)
                    }
                }
            } else {
                itemProvider.loadObject(ofClass: UIImage.self) {reading, err in
                    if let img = reading as? UIImage {
                        self.imageHandler(img)
                    }
                }
            }
            
        }
    }
}


// MARK: - Files

extension NewItemViewController: UIDocumentPickerDelegate {
    func openDocumentPicker() {
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = false
        pickerViewController.shouldShowFileExtensions = true
        self.present(pickerViewController, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        dismiss(animated: true)
    }
}
