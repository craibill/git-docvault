//
//  PersonClass.swift
//  SimpleList
//
//  Created by Craig Billings on 2/21/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import Foundation
import UIKit

class PersonClass {
    
    var name: String = ""
    var image: UIImage?
    var imageThumb: UIImage?
    var wtf: String = ""
    
    init?(name: String, image: UIImage?) {

        self.name = name
        self.image = image
        self.imageThumb = resizeImage(image: self.image!, targetSize: CGSize(width: 1000.0, height: 1000.0))
        
        // comment for Git
        // next comment
        
        
    }


private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
    
    }

}

