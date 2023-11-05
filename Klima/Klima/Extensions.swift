//
//  Extensions.swift
//  Klima
//
//  Created by luegm.dev on 03.11.23.
//

import Foundation
import SwiftUI

extension UIImage {
    /// Scales the image to a maximum dimension (width or height).
    func scaledDown(to maxDimension: CGFloat) -> UIImage {
        let aspectRatio: CGFloat = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * aspectRatio, height: size.height * aspectRatio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func cropping(to rect: CGRect) -> UIImage? {
            guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
            return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        }
}
