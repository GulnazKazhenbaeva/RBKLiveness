////
////  UIView+Extensions.swift
////  RBKLiveness
////
////  Created by Gulnaz on 12/20/20.
////  Copyright © 2020 Gulnaz. All rights reserved.
////
//
import UIKit

public extension UIView {
    func cornered(radius: CGFloat = 20.0) {
        clipsToBounds = true
        layer.cornerRadius = radius
    }
}
