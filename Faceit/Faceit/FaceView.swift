//
//  FaceView.swift
//  Faceit
//
//  Created by Emmet Susslin on 5/25/17.
//  Copyright © 2017 Emmet Susslin. All rights reserved.
//

import UIKit

class FaceView: UIView {

    //PUBLIC API - @Instectable
    
    @IBInspectable var scale: CGFloat = 0.9 {  didSet { setNeedsDisplay() } }
    @IBInspectable var eyesOpen: Bool = true  {  didSet { setNeedsDisplay() } }
    @IBInspectable var mouthCurvature: Double = 1.0 {  // 1.0 is full smile, and -1.0 is full frown
        didSet { setNeedsDisplay() } }
    @IBInspectable var lineWidth: CGFloat = 5.0  {  didSet { setNeedsDisplay() } }
    @IBInspectable var color: UIColor = UIColor.blue     {  didSet { setNeedsDisplay() } }
    
    
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer)
    {
        switch pinchRecognizer.state {
        case .changed, .ended:
            scale *= pinchRecognizer.scale
            print("scale = \(scale)")
            // reset size to 1.0
            pinchRecognizer.scale = 1.0
        default:
            break
        }
    }
    
    
    private var skullRadius: CGFloat {
        
        return min(bounds.size.width, bounds.size.height) / 2 * scale
        
    }
    
    
    private var skullCenter: CGPoint {
        
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private enum Eye {
        case left
        case right
        
    }
    
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRadius
        let eyeCenter = centerOfEye(eye)
        
        let path: UIBezierPath
        
        if eyesOpen {
        
        path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
       
        } else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        path .lineWidth = 5.0
        return path
    }
    
    private func pathForMouth() -> UIBezierPath {
        
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeight
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
        
        let mouthOrigin = CGPoint(x: skullCenter.x - mouthWidth/2, y: skullCenter.y + mouthOffset)
        let mouthSize = CGSize(width: mouthWidth, height: mouthHeight)
        let mouthRect = CGRect(origin: mouthOrigin, size: mouthSize)
        
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: end.y + smileOffset)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path    }
    
    
    
    private func pathForSkull() -> UIBezierPath {
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: CGFloat(0), endAngle: 2 * CGFloat.pi, clockwise: false)
        path.lineWidth = 5.0
        return path
    }
    
    
    
    
    override func draw(_ rect: CGRect) {
        UIColor.blue.set()
        pathForSkull().stroke()
        pathForEye(.left).stroke()
        pathForEye(.right).stroke()
        pathForMouth().stroke()
    }
    
    private struct Ratios {
        
        static let skullRadiusToEyeOffset: CGFloat = 3
        static let skullRadiusToEyeRadius: CGFloat = 10
        static let skullRadiusToMouthWidth: CGFloat = 1
        static let skullRadiusToMouthHeight: CGFloat = 3
         static let skullRadiusToMouthOffset: CGFloat = 3
        
    }
}
