//
//  ItemDetailsViewController.swift
//  WishList
//
//  Created by Marko Kos on 28.12.2022..
//

import UIKit
import SnapKit

class ItemDetailsViewController: UIViewController, UIScrollViewDelegate, UIContextMenuInteractionDelegate {
    
    var item: Item?
    
    let scrollView = UIScrollView()
    
    let headerImageView = UIView()
    let imageView = UIImageView()
        
    let contentStackView = UIStackView()
    let nameLabel = UILabel()
    let subtitleStackView = UIStackView()
    let subtitleSeparatorView = UIView()
    let categoryView = WLLabelWithIcon()
    let websiteView = WLLabelWithIcon()
    let priceLabel = UILabel()
    let descriptionTitleLabel = UILabel()
    let descriptionLabel = UILabel()
    
    
    let customMoreButton = UIButton()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
        setupConstraints()
        
        guard let item = item else {
            print("Missing item")
            return
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func openMenu() {
        print("openMenu")
    }
    
    func buildMenu() -> UIMenu {
        let editAction = UIAction(title: "Edit...", image: UIImage(systemName: "ellipsis"), identifier: nil) { action in
            
        }
        
        let editMenu = UIMenu(options: .displayInline, children: [editAction])
        
        let categoriesAction = UIAction(title: "Categories", image: nil, identifier: nil, discoverabilityTitle: nil) { action in
        }
        let action1 = UIAction(title: "Accessories") { action in }
        let action2 = UIAction(title: "Clothing") { action in }
        let action3 = UIAction(title: "Sneakers") { action in }
        let action4 = UIAction(title: "Tech") { action in }
        
        let categoriesMenu = UIMenu(title: "Categories", image: UIImage(systemName: "tag"), options: .singleSelection, children: [action1, action2, action3, action4])
        
        /// Share Menu
        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), identifier: nil, discoverabilityTitle: nil) { action in
        }
        let openInBrowserAction = UIAction(title: "Open in Browser", image: UIImage(systemName: "safari"), identifier: nil, discoverabilityTitle: nil) { action in
        }
        let shareMenu = UIMenu(title: "", options: .displayInline, children: [shareAction, openInBrowserAction])
        
        /// Duplicate Menu
        let duplicateAction = UIAction(title: "Duplicate...", image: UIImage(systemName: "plus.square.on.square"), identifier: nil, discoverabilityTitle: nil) { action in
        }
        let duplicateMenu = UIMenu(title: "", options: .displayInline, children: [duplicateAction])
        
        /// Delete Menu
        let deleteAction = UIAction(title: "Delete...", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive) { action in
        }
        let deleteMenu = UIMenu(title: "", options: .displayInline, children: [deleteAction])
        
        return UIMenu(image: nil, identifier: nil, options: [], children: [editMenu, categoriesMenu, shareMenu, duplicateMenu, deleteMenu])
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: {
                suggestedActions in
            return self.buildMenu()
        })
    }
    
    private func updateUI() {
        view.backgroundColor = UIColor.white
        
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(openMenu))
//        view.addGestureRecognizer(longPressGesture)
        
        guard let item = item else {
            print("Missing item")
            return
        }
        
        
        /// Scroll View
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(scrollView)
        
        /// Header View

        if item.hasItemFirstImage {
            guard let image = item.firstItemImage?.image else {
                return
            }
            
            headerImageView.backgroundColor = .gray
            self.scrollView.addSubview(headerImageView)
            
            imageView.image = UIImage(data: image)
            imageView.clipsToBounds = true
            imageView.backgroundColor = .green
            imageView.contentMode = .scaleAspectFill
            headerImageView.addSubview(imageView)
        }
        
        /// Content Stack View
        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.distribution = .fill
        contentStackView.alignment = .leading
        
        /// Name Label
        nameLabel.text = item.name
        nameLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        nameLabel.numberOfLines = 0
        
        /// Subtitle
        subtitleStackView.axis = .horizontal
        subtitleStackView.spacing = 8
        subtitleStackView.distribution = .fillProportionally
        subtitleStackView.alignment = .center
        
        categoryView.label.font = .systemFont(ofSize: 12, weight: .medium)
        categoryView.imageView.image = UIImage(systemName: "tag.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .small))?.withTintColor(.black, renderingMode: .alwaysOriginal)
        if let categories = item.categories {
            categoryView.isHidden = false
            let categories = categories as! Set<Category>
            categoryView.label.text = categories.map { $0.name ?? "" }.lazy.joined(separator: ", ")
        } else {
            categoryView.isHidden = true
        }
        
        subtitleSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        subtitleSeparatorView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        if let website = item.website,
           item.categories?.count == 0 || website.isEmpty {
            subtitleSeparatorView.isHidden = true
        } else {
            subtitleSeparatorView.isHidden = false
        }
        
        websiteView.label.font = .systemFont(ofSize: 12, weight: .medium)
        websiteView.imageView.image = UIImage(systemName: "book.closed.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .small))?.withTintColor(.black, renderingMode: .alwaysOriginal)
        if let website = item.website,
           website.isEmpty {
            websiteView.isHidden = true
        } else {
            websiteView.isHidden = false
            websiteView.label.text = item.website
        }
        
        subtitleStackView.addArrangedSubview(categoryView)
        subtitleStackView.addArrangedSubview(subtitleSeparatorView)
        subtitleStackView.addArrangedSubview(websiteView)
        
        /// Price Label
//        priceLabel.text = item?.price
        priceLabel.font = .systemFont(ofSize: 16)
        priceLabel.textColor = .gray
        
        /// Description Title Label
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        /// Description Label
        let attributedString = NSMutableAttributedString(string: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        descriptionLabel.attributedText = attributedString
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .gray
//        self.scrollView.addSubview(descriptionLabel)
        
//        mainStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(subtitleStackView)
        contentStackView.addArrangedSubview(priceLabel)
        contentStackView.addArrangedSubview(descriptionTitleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        
        contentStackView.setCustomSpacing(32, after: priceLabel)
        contentStackView.setCustomSpacing(16, after: descriptionTitleLabel)

        self.scrollView.addSubview(contentStackView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemThinMaterial)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect)
        
        var customBackButtonConfig = UIButton.Configuration.tinted()
        customBackButtonConfig.background.customView = blurEffectView1
        customBackButtonConfig.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .black))
        customBackButtonConfig.baseForegroundColor = .black.withAlphaComponent(0.5)
        customBackButtonConfig.cornerStyle = .capsule
        let customBackButton = UIButton(configuration: customBackButtonConfig, primaryAction: UIAction { _ in self.goBack()} )
        customBackButton.configurationUpdateHandler = { button in
            if button.isHighlighted {
                var config = button.configuration
                config?.imageColorTransformer = UIConfigurationColorTransformer { _ in
                    return .black.withAlphaComponent(0.7)
                }
                button.configuration = config
            }
        }
        
        
        self.view.addSubview(customBackButton)
        customBackButton.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.left.equalTo(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        
        
        var customRightButtonConfig = UIButton.Configuration.tinted()
        customRightButtonConfig.background.customView = blurEffectView2
        customRightButtonConfig.image = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .black))
        customRightButtonConfig.baseForegroundColor = .black.withAlphaComponent(0.5)
        customRightButtonConfig.cornerStyle = .capsule
        let customRightButton = UIButton(configuration: customRightButtonConfig)
        customRightButton.configurationUpdateHandler = { button in
            if button.isHighlighted {
                var config = button.configuration
                config?.imageColorTransformer = UIConfigurationColorTransformer { _ in
                    return .black.withAlphaComponent(0.7)
                }
                button.configuration = config
            }
        }

        self.view.addSubview(customRightButton)
        customRightButton.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.right.equalTo(-20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        
        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
        customRightButton.menu = buildMenu()
        customRightButton.showsMenuAsPrimaryAction = true
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        guard let item else {
            return
        }
        
        print("setupConstraints")
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        var height: CGFloat = 0
        print(item.firstItemImage)
        if let itemImage = item.firstItemImage?.image {
            let image = UIImage(data: itemImage)!
            print("image \(image)")
            print(image.size)
            
            let targetSize = self.view.frame.size

            let widthScaleRatio = targetSize.width / image.size.width
            print("widthScaleRatio: \(widthScaleRatio)")

            let heightScaleRatio = targetSize.height / image.size.height
            print("heightScaleRatio: \(heightScaleRatio)")

            let scaleFactor = min(widthScaleRatio, heightScaleRatio)
            print("scaleFactor: \(scaleFactor)")

            let scaledImageSize = CGSize(
                width: image.size.width * scaleFactor,
                height: image.size.height * scaleFactor
            )
            
            print("scaledImageSize: \(scaledImageSize)")
            
            if image.isLandscape {
                print("image is landscape")
                height = scaledImageSize.height
            } else if image.isPortrait {
                print("image is portrait")
                height = 280
            } else if image.isSquare {
                print("image is square")
                height = scaledImageSize.height
            } else {
                print("image is undefined scale")
                height = 280
            }
        }
        
        print("height: \(height)")
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-24)
            make.top.equalTo(scrollView.snp.top).offset(height)
        }
        
        if item.hasItemFirstImage {
            headerImageView.translatesAutoresizingMaskIntoConstraints = false
            headerImageView.snp.makeConstraints { make in
                make.top.equalTo(view.snp.top)
                make.leading.equalTo(view.snp.leading)
                make.trailing.equalTo(view.snp.trailing)
                make.bottom.equalTo(contentStackView.snp.top).offset(-24).priority(900)
            }

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.snp.makeConstraints { make in
                make.leading.equalTo(headerImageView.snp.leading)
                make.trailing.equalTo(headerImageView.snp.trailing)
                make.bottom.equalTo(headerImageView.snp.bottom)
                make.top.equalTo(view.snp.top).priority(900)
            }
        }
        
        
        
        subtitleSeparatorView.snp.makeConstraints { make in
            make.height.equalTo(18).priority(.high)
            make.width.equalTo(1)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // TODO: Popraviti nekako bounce efekt kad se previše odscrolla pa skoči prema gore
        if let item = item, item.hasItemFirstImage {
            guard let itemImage = item.firstItemImage?.image else {
                return
            }
            
            let image = UIImage(data: itemImage)!

            print(image.size)
            print(self.view.frame)

            if image.size.width < image.size.height {
                let targetSize = self.view.frame.size

                let widthScaleRatio = targetSize.width / image.size.width
                print("widthScaleRatio: \(widthScaleRatio)")

                let heightScaleRatio = targetSize.height / image.size.height
                print("heightScaleRatio: \(heightScaleRatio)")

                let scaleFactor = min(widthScaleRatio, heightScaleRatio)
                print("scaleFactor: \(scaleFactor)")

                let scaledImageSize = CGSize(
                    width: image.size.width * scaleFactor,
                    height: image.size.height * scaleFactor
                )
                print("scaledImageSize: \(scaledImageSize)")

                UIView.animate(withDuration: 0.3) {
                    self.contentStackView.snp.updateConstraints { make in
                        make.top.equalTo(scrollView.snp.top).offset(scaledImageSize.height)
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

}
