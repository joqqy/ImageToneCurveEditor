//
//  ImageWidget.swift
//  ToneCurveEditor
//
//  Created by Simon Gladman on 12/09/2014.
//  Copyright (c) 2014 Simon Gladman. All rights reserved.
//

import UIKit

class ImageWidget: UIControl , UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    let blurOveray = UIVisualEffectView(effect: UIBlurEffect())
    let loadImageButton = UIButton(frame: CGRect.zero)
    let imageView = UIImageView(frame: CGRect.zero)
    let activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
    
    let ciContext = CIContext(options: nil)
    let filter = CIFilter(name: "CIToneCurve")
    
//    var backgroundBlock : Async?
    var loadedImage : UIImage?
    var filteredImage : UIImage?
    
    weak var viewController : UIViewController?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
 
        backgroundColor = UIColor.black
        
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        addSubview(imageView)
        addSubview(blurOveray)
        
        loadImageButton.setTitle("Load Image", for: .normal)
        loadImageButton.setTitleColor(UIColor.black, for: .normal)
        
        loadImageButton.addTarget(self, action: #selector(ImageWidget.loadImageButtonClickHandler(_:)), for: .touchUpInside)
        
        addSubview(loadImageButton)
        
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.color = UIColor.black
        addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    @objc func loadImageButtonClickHandler(_ button : UIButton)
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.isModalInPopover = false
        imagePicker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        
        viewController!.present(imagePicker, animated: true, completion: nil)
    }
    
    var filterIsRunning : Bool = false
    {
        didSet
        {
            if filterIsRunning
            {
                activityIndicator.startAnimating()
            }
            else
            {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    var curveValues: [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
    {
        didSet
        {
            applyFilterAsync()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
//        backgroundBlock?.cancel()
//        backgroundBlock = nil
        
        filterIsRunning = false
        
        if let rawImage = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        {
            loadedImage = rawImage.resizeToBoundingSquare(boundingSquareSideLength: 1024)
            
            applyFilterAsync()
        }

        viewController!.dismiss(animated: true, completion: nil)
    }


    
    func applyFilterAsync()
    {
      
        
        DispatchQueue.global(qos: .background).async {
            
            guard !self.filterIsRunning, let filter = self.filter,
                let loadedImage = self.loadedImage else {
                    return
            }
          
            self.filterIsRunning = true
            self.filteredImage = ImageWidget.applyFilter(loadedImage: loadedImage, curveValues: self.curveValues, ciContext: self.ciContext, filter: filter)

            DispatchQueue.main.async {
                self.imageView.image = self.filteredImage
                self.filterIsRunning = false
            }
        }
        
//        backgroundBlock = Async.background
//        {
//
//        }
//        .main
//        {
//
//        }
    }
    
    
    class func applyFilter(loadedImage loadedImage: UIImage, curveValues: [Double], ciContext: CIContext, filter: CIFilter) -> UIImage
    {
        let coreImage = CIImage(image: loadedImage)
        
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        
        filter.setValue(CIVector(x: 0.0, y: CGFloat(curveValues[0])), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: CGFloat(curveValues[1])), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: CGFloat(curveValues[2])), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: CGFloat(curveValues[3])), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1.0, y: CGFloat(curveValues[4])), forKey: "inputPoint4")
        
        let filteredImageData = filter.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let filteredImage = UIImage(cgImage: filteredImageRef!)
       
        return filteredImage
    }
    
    override func layoutSubviews()
    {
        blurOveray.frame = CGRect(x: 0, y: frame.height - 50, width: frame.width, height: 50)
   
        loadImageButton.frame = CGRect(x: 20, y: frame.height - 50, width: 100, height: 50)
    
        imageView.frame = CGRect(x: 5, y: 5, width: frame.width - 10, height: frame.height - 10)
        
        activityIndicator.frame = CGRect(x: frame.width - 20, y: frame.height - 25, width: 0, height: 0)
    }
}
