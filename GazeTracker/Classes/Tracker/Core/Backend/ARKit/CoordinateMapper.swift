//
//  CoordinateMapper.swift
//  GazeTracker
//
//  Created by Enoxus on 14.05.2022.
//

import DeviceKit
import Foundation

public protocol CoordinateMapper {
    /// Transforms point from metric to logic coordinate system
    func mapCoordinates(from point: CGPoint) -> CGPoint
}

public struct OrientationAwareCoordinateMapper: CoordinateMapper {
    public init() {}
    
    public func mapCoordinates(from point: CGPoint) -> CGPoint {
        switch UIDevice.current.orientation {
        case .portrait, .faceUp:
            return portraitCoordinateMapping(point)
        case .landscapeRight:
            return landscapeRightCoordinateMapping(point)
        case .portraitUpsideDown:
            return portraitUpsideDownCoordinateMapping(point)
        case .landscapeLeft:
            return landscapeLeftCoordinateMapping(point)
        default:
            return portraitCoordinateMapping(point)
        }
    }

    private func portraitCoordinateMapping(_ point: CGPoint) -> CGPoint {
        let xPartial = point.x / (Device.current.realScreenSize.width / 2)
        let yPartial = point.y / (Device.current.realScreenSize.height / 2)

        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width + Device.current.pointScreenSize.width * Device.current.leadingFrontalCameraOffset
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height

        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
    
    private func landscapeLeftCoordinateMapping(_ point: CGPoint) -> CGPoint {
        let xPartial = point.x / (Device.current.realScreenSize.height / 2)
        let yPartial = point.y / (Device.current.realScreenSize.width / 2)
        
        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height - Device.current.pointScreenSize.height * Device.current.leadingFrontalCameraOffset
        
        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
    
    private func landscapeRightCoordinateMapping(_ point: CGPoint) -> CGPoint {
        let xPartial = point.x / (Device.current.realScreenSize.height / 2)
        let yPartial = point.y / (Device.current.realScreenSize.width / 2)
        
        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width + Device.current.pointScreenSize.width
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height - Device.current.pointScreenSize.height * (1 - Device.current.leadingFrontalCameraOffset)
        
        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
    
    private func portraitUpsideDownCoordinateMapping(_ point: CGPoint) -> CGPoint {
        let xPartial = point.x / (Device.current.realScreenSize.width / 2)
        let yPartial = point.y / (Device.current.realScreenSize.height / 2)

        let eyeLookAtPositionX = xPartial * Device.current.pointScreenSize.width + (Device.current.pointScreenSize.width * 1 - Device.current.leadingFrontalCameraOffset)
        let eyeLookAtPositionY = yPartial * Device.current.pointScreenSize.height + Device.current.pointScreenSize.height

        return CGPoint(x: eyeLookAtPositionX, y: -eyeLookAtPositionY)
    }
}
