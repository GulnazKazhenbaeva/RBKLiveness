////
////  UIImage+Extensions.swift
////  RBKLiveness
////
////  Created by Gulnaz on 12/20/20.
////  Copyright © 2020 Gulnaz. All rights reserved.
////

import UIKit

public extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        let renderingMode = self.renderingMode
        // Perform image resizing
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: rect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result?.withRenderingMode(renderingMode)
    }
}
