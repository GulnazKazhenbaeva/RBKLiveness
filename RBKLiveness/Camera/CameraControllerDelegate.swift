//
//  CameraControllerDelegate.swift
//  RBKLiveness
//
//  Created by Gulnaz on 1/15/21.
//  Copyright © 2021 rbk. All rights reserved.
//

import UIKit

public protocol CameraControllerDelegate: class {
    /// called on error
    func handleError(_ error: String)
}
