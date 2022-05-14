//
//  Device+Extensions.swift
//  DeviceKit
//
//  Created by Enoxus on 08.03.2022.
//

import DeviceKit

extension Device {
    /// real screen size in meters
    public var realScreenSize: (width: Double, height: Double) {
        let diagonalFraction = (screenRatio.height.squared + screenRatio.width.squared).squareRoot()
        let widthInches = screenRatio.width / diagonalFraction * diagonal
        let heightInches = screenRatio.height / diagonalFraction * diagonal
        
        return (
            width: inchesToMeters(from: widthInches),
            height: inchesToMeters(from: heightInches)
        )
    }
    
    /// screen size in points with respect to orientation
    public var pointScreenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    /// fraction of screen width between its leading corner and  frontal camera
    public var leadingFrontalCameraOffset: Double {
        switch self {
        case .iPhone12Mini:
            return 0.5// 0.603448275862069
            
        default:
            // TODO: добавить больше известных моделей
            return 0.5
        }
    }
}

private func inchesToMeters(from inches: Double) -> Double {
    return inches * 2.54 / 100.0
}

private extension Double {
    var squared: Double {
        return self * self
    }
}
