////
////  Array+Extensions.swift
////  RBKLiveness
////
////  Created by Gulnaz on 12/20/20.
////  Copyright © 2020 Gulnaz. All rights reserved.
////

import UIKit

public extension Array {
    func getRandom() -> Element {
        let lower: UInt32 = 0
        let upper: UInt32 = (UInt32(self.count))
        let randomNumber = arc4random_uniform(upper - lower) + lower
        return self[Int(randomNumber)]
    }
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
