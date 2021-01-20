//
//  LivenessManager.swift
//  mb_rbk
//
//  Created by Gulnaz on 12/12/19.
//  Copyright © 2019 Gulnaz. All rights reserved.
//

import UIKit
import MLKitVision
import MLKitFaceDetection

class LivenessManager {
    private let RATIO: CGFloat = 0.5
    struct Point {
        let x: CGFloat
        let y: CGFloat
    }
    
    func getDistance(_ first: [Point], _ second: [Point]) -> CGFloat {
        var sum: CGFloat = 0
        for i in 0..<first.count {
            let x1 = first[i].x
            let x2 = second[i].x
            let y1 = first[i].y
            let y2 = second[i].y
            let dictanceX = pow((x1 - x2), 2)
            let dictanceY = pow((y1 - y2), 2)
            let distance = (dictanceX + dictanceY).squareRoot()
            sum += distance
        }
        return sum / CGFloat(first.count)
    }
    
    func checkOpenMouth(_ face: Face) -> Bool {
        guard let mounthHeight = getMouthHeight(face),
            let lipTopHeight = getLipTopHeight(face),
            let lipBottomHeight = getLipBottomHeight(face) else {
                return false
        }
        return mounthHeight > min(lipTopHeight, lipBottomHeight) * RATIO
    }
    
    private func getMouthHeight(_ face: Face) -> CGFloat? {
        let top = face.contour(ofType: .upperLipBottom)?.points.map {
            return Point(x: $0.x, y: $0.y)
        }
        let bottom = face.contour(ofType: .lowerLipTop)?.points.map {
            return Point(x: $0.x, y: $0.y)
        }
        guard let upper = top, let lower = bottom,
            upper.count > 5, lower.count > 5 else {
            return nil
        }
        let upperPoints = [upper[3], upper[4], upper[5]]
        let lowerPoints = [lower[5], lower[4], lower[3]]
        return getDistance(upperPoints, lowerPoints)
    }
    private func getLipTopHeight(_ face: Face) -> CGFloat? {
        let top = face.contour(ofType: .upperLipTop)?.points.map {
            return Point(x: $0.x, y: $0.y)
        }
        let bottom = face.contour(ofType: .upperLipBottom)?.points.map {
            return Point(x: $0.x, y: $0.y)
        }
        guard let upper = top, let lower = bottom,
            upper.count > 6, lower.count > 5 else {
            return nil
        }
        let upperPoints = [upper[4], upper[5], upper[6]]
        let lowerPoints = [lower[3], lower[4], lower[5]]
        return getDistance(upperPoints, lowerPoints)
    }
    private func getLipBottomHeight(_ face: Face) -> CGFloat? {
        let top = face.contour(ofType: .lowerLipTop)?.points.map {
            return Point(x: $0.x, y: $0.y)
        }
        let bottom = face.contour(ofType: .lowerLipBottom)?.points.map {
            return Point(x: $0.x, y: $0.y)
        }
        guard let upper = top, let lower = bottom,
            upper.count > 5, lower.count > 5 else {
            return nil
        }
        let upperPoints = [upper[3], upper[4], upper[5]]
        let lowerPoints = [lower[3], lower[4], lower[5]]
        return getDistance(upperPoints, lowerPoints)
    }
}
