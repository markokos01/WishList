//
//  UIImage+Extensions.swift
//  WishList
//
//  Created by Marko Kos on 12.01.2023..
//

import UIKit

extension UIImage {
    
    var isLandscape: Bool {
        print("isLandscape: \(self.size)")
        return self.size.width > self.size.height
    }
    
    var isPortrait: Bool {
        print("isPortrait: \(self.size)")
        return self.size.width < self.size.height
    }
    
    var isSquare: Bool {
        print("isSquare: \(self.size)")
        return self.size.width == self.size.height
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            
            return scaledImage
        }
    
}
