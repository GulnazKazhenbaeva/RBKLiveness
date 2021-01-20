//
//  LivenessValidationType.swift
//  RBKLiveness
//
//  Created by Gulnaz on 1/19/21.
//  Copyright © 2021 rbk. All rights reserved.
//

import UIKit

enum LivenessValidationType {
    case smile
    case turnLeft
    case turnRight
    case leanLeft
    case leanRight
    case blink
    case openMouth
    
    var title: String {
        switch self {
        case .smile: return RBKLivenessConfig.smileTitle
        case .turnLeft: return RBKLivenessConfig.turnLeftTitle
        case .turnRight: return RBKLivenessConfig.turnRightTitle
        case .leanLeft: return RBKLivenessConfig.leanLeftTitle
        case .leanRight: return RBKLivenessConfig.leanRightTitle
        case .blink: return RBKLivenessConfig.blinkTitle
        case .openMouth: return RBKLivenessConfig.openMouthTitle
        }
    }
}
