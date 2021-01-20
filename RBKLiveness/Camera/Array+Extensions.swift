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

extension LivenessValidationType {

    static func prepareActions() -> [LivenessValidationType] {
        var actions: [LivenessValidationType] = []
        let headActions: [LivenessValidationType] = [.turnLeft, .turnRight]
        let faceActions: [LivenessValidationType] = [.smile, .blink]
        while actions.count < 2 {
            let headAction = headActions.getRandom()
            if !actions.contains(headAction) {
                actions.append(headAction)
            }
        }
        while actions.count < 4 {
            let faceAction = faceActions.getRandom()
            if !actions.contains(faceAction) {
                actions.append(faceAction)
            }
        }
        return actions
    }
}
