//
//  ToneCurveEditorCurveLayer.swift
//  ToneCurveEditor
//
//  Created by Simon Gladman on 13/09/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit
import CoreGraphics

class ToneCurveEditorCurveLayer: CALayer
{
    weak var toneCurveEditor : ToneCurveEditor?
    
    override func draw(in ctx: CGContext)
    {
        if let curveValues = toneCurveEditor?.curveValues
        {
            let path = UIBezierPath()
    
            let margin = 20
            let thumbRadius = 15
            let widgetWidth = Int(frame.width)
            let widgetHeight = Int(frame.height) - margin - margin - thumbRadius - thumbRadius

            var interpolationPoints : [CGPoint] = [CGPoint]()
            
            for (i, value): (Int, Double) in curveValues.enumerated()
            {
                let pathPointX = i * (widgetWidth / curveValues.count) + (widgetWidth / curveValues.count / 2)
                let pathPointY = thumbRadius + margin + widgetHeight - Int(Double(widgetHeight) * value)
                
                interpolationPoints.append(CGPoint(x: pathPointX,y: pathPointY))
            }
     
            path.interpolatePointsWithHermite(interpolationPoints: interpolationPoints)
       
            ctx.setLineJoin(CGLineJoin.round)
            ctx.addPath(path.cgPath)
            ctx.setStrokeColor(UIColor.blue.cgColor)
            ctx.setLineWidth(6)
            ctx.strokePath()
        }
    }


    
}
