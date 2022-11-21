//
//  ToneCurveEditor.swift
//  ToneCurveEditor
//
//  Created by Simon Gladman on 12/09/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ToneCurveEditor: UIControl
{
    let formatString = "%.03f"
    
    var sliders = [UISlider]()
    var labels = [UILabel]()
    let curveLayer = ToneCurveEditorCurveLayer()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        curveLayer.toneCurveEditor = self
        curveLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(curveLayer)
  
        createSliders()
        createLabels()
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    var curveValues: Array<Double> = Array.init(repeating: 0, count: 5)
    {
        didSet
        {
            for (i, value): (Int, Double) in curveValues.enumerated()
            {
                sliders[i].value = Float(value)
                labels[i].text = String(format: formatString, value)
            }
            
            drawCurve()
        }
    }
    
    func createSliders()
    {
        let rotateTransform: CGAffineTransform = .identity
        
        for _ in 0..<5
        {
            let slider = UISlider(frame: CGRect.zero)
  
            slider.transform = rotateTransform.rotated(by: CGFloat(-90.0 * CGFloat.pi / 180.0));
            slider.addTarget(self, action: #selector(ToneCurveEditor.sliderChangeHandler(_:)), for: .valueChanged)
            
            sliders.append(slider)
            
            addSubview(slider)
        }
    }
    
    func createLabels()
    {
        for _ in 0..<5
        {
            let label = UILabel(frame: CGRect.zero)
            
            //label.textAlignment = NSTextAlignment(rawValue: 2)!
            
            labels.append(label)
            
            addSubview(label)
        }
    }
    
    func drawCurve()
    {
        curveLayer.frame = bounds.insetBy(dx: 0, dy: 0)
        curveLayer.setNeedsDisplay()
    }
    
    @objc func sliderChangeHandler(_ slider : UISlider)
    {
        let index = sliders.firstIndex(of: slider)
        curveValues[index!] = Double(slider.value)
        let label = labels[index!]
        label.text = String(format: formatString, slider.value)
        
        sendActions(for: .valueChanged)
    }
    
    override func layoutSubviews()
    {
        let margin = 20
        let targetHeight = Int(frame.height) - margin - margin
        let targetWidth = Int(frame.width) / sliders.count
        
        for (i, slider): (Int, UISlider) in sliders.enumerated()
        {
            let targetX = i * Int(frame.width) / sliders.count

            slider.frame = CGRect(x: targetX, y: margin, width: targetWidth, height: targetHeight)
        }
        
        for (i, label): (Int, UILabel) in labels.enumerated()
        {
            let targetX = i * Int(frame.width) / labels.count
            
            label.frame = CGRect(x: targetX + (targetWidth / 2) + (margin / 5), y: (targetHeight - (margin / 5)), width: targetWidth - (margin * 2), height: margin)
        }
        
        drawCurve()
    }

}
