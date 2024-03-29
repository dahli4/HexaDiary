//
//  WindowDrawingHelper.swift
//  EveryDiary
//
//  Created by t2023-m0099 on 3/27/24.
//

import UIKit

struct BuildingSize {
    let position: CGPoint
    let size: CGSize
    let windowLayout: WindowLayout
}

struct WindowLayout {
    let columns: [[Int]]
}

class WindowDrawingHelper {
    static func drawBuildingWithWindows(buildings: [BuildingSize], onLayer layer: CALayer, diaryDays: Set<Int>) {
        drawWindowInBuilding(buildings: buildings, onLayer: layer, diaryDays: diaryDays)
    }
    
    static func createWindowLayer(at position: CGPoint, color: UIColor, windowSize: CGSize) -> CAShapeLayer {
        let windowPath = UIBezierPath(rect: CGRect(origin: position, size: windowSize))
        let windowLayer = CAShapeLayer()
        windowLayer.path = windowPath.cgPath
        windowLayer.fillColor = color.cgColor
        return windowLayer
    }
    
    static func drawWindowInBuilding(buildings: [BuildingSize], onLayer layer: CALayer, diaryDays: Set<Int>) {
        guard !buildings.isEmpty else { return }
        var windowOrder = 1
        for building in buildings {
            handleBuilding(building, onLayer: layer, diaryDays: diaryDays, windowOrder: &windowOrder)
        }
    }
    
    static func handleBuilding(_ building: BuildingSize, onLayer layer: CALayer, diaryDays: Set<Int>, windowOrder: inout Int) {
        for (i, row) in building.windowLayout.columns.enumerated() {
            handleFloor(i, row, building, onLayer: layer, diaryDays: diaryDays, windowOrder: &windowOrder)
        }
    }
    
    static func handleFloor(_ floorIndex: Int, _ floorWindows: [Int], _ building: BuildingSize, onLayer layer: CALayer, diaryDays: Set<Int>, windowOrder: inout Int) {
        for (windowIndex, windowColumns) in floorWindows.enumerated() {
            if windowColumns == 0 { continue }
            let windowWidth = building.size.width / CGFloat(windowColumns)
            let windowHeight = building.size.height / CGFloat(building.windowLayout.columns.count)
            let windowPosition = CGPoint(x: building.position.x + windowWidth * CGFloat(windowIndex), y: building.position.y - windowHeight * CGFloat(floorIndex+1))
            let windowSize = CGSize(width: 10, height: 22)
            if !diaryDays.isEmpty && windowOrder <= diaryDays.count {
                cacheWindowImageIfNeeded(windowIndex: windowOrder, color: .yellow, windowSize: windowSize)
                let windowLayer = createWindowLayer(at: windowPosition, color: .yellow, windowSize: windowSize)
                layer.addSublayer(windowLayer)
                windowOrder += 1
            } else {
                cacheWindowImageIfNeeded(windowIndex: windowOrder, color: .darkGray, windowSize: CGSize(width: windowWidth, height: windowHeight))
                let windowLayer = createWindowLayer(at: windowPosition, color: .darkGray, windowSize: windowSize)
                layer.addSublayer(windowLayer)
            }
        }
    }
    
    static func cacheWindowImageIfNeeded(windowIndex: Int, color: UIColor, windowSize: CGSize) {
        if MotivationImageCache.shared.getImage(forKey: "window_\(windowIndex)") != nil {
            return
        } else {
            let renderer = UIGraphicsImageRenderer(size: windowSize)
            let windowImage = renderer.image { context in
                color.setFill()
                context.fill(CGRect(origin: .zero, size: windowSize))
            }
            MotivationImageCache.shared.setImage(windowImage, forKey: "window_\(windowIndex)")
        }
    }
}
