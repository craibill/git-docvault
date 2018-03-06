//
//  Item.swift
//  SimpleList
//
//  Created by Craig Billings on 2/21/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import Foundation
import UIKit

class ItemClass {
    
    var id: String = ""
    var description: String = ""
    var imageThumb: UIImage?
    var image: UIImage?
    //var descriptionDidChange: Bool = false
    //var imageDidChange: Bool = false
    //var thumbSize: CGSize = CGSize(width: 300.0, height: 300.0)
    var thumbSize: CGSize = CGSize(width: 90.0, height: 90.0)

    
    init?(description: String, image: UIImage?) {

        // create a unique id
        self.id = NSUUID().uuidString
        self.description = description
        self.image = image
        // create a thumb sized image
        self.imageThumb = resizeImage(image: self.image!, targetSize: thumbSize)
        
        print("image.size.width: \(image?.size.width), image.size.height: \(image?.size.height)")
        print("imageThumb.size.width: \(imageThumb?.size.width), imageThumb.size.height: \(imageThumb?.size.height)")

    }

    init?(id: String, description: String, fullSizeImage: UIImage, thumbSizeImage: UIImage) {
        
        self.id = id
        self.description = description
        self.image = fullSizeImage
        self.imageThumb = thumbSizeImage
    }

    func createThumbsizeImage() {
    
        self.imageThumb = resizeImage(image: self.image!, targetSize: thumbSize)
        print("image.size.width: \(image?.size.width), image.size.height: \(image?.size.height)")
        print("imageThumb.size.width: \(imageThumb?.size.width), imageThumb.size.height: \(imageThumb?.size.height)")
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        var img: UIImage = image
        
        // Define thumbnail size
        //let size = CGSize(width: 90, height: 90)
        
        // Define rect for thumbnail
        let scale = max(targetSize.width/img.size.width, targetSize.height/img.size.height)
        let width = img.size.width * scale
        let height = img.size.height * scale
        let x = (targetSize.width - width) / CGFloat(2)
        let y = (targetSize.height - height) / CGFloat(2)
        let thumbnailRect = CGRect(x: x, y: y, width: width, height: height)
        
        // Generate thumbnail from image
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        img.draw(in: thumbnailRect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail!
        
        /*
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
        */
    }

}

