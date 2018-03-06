//
//  ZoomImageViewController.swift
//  DocVault
//
//  Created by Craig Billings on 2/18/18.
//  Copyright © 2018 Craig Billings. All rights reserved.
//

import UIKit

class ZoomImageViewController: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var scrollViewObject: UIScrollView!
    @IBOutlet weak var imageViewObject: UIImageView!
    
    @IBOutlet weak var imageViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var imageViewTop: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeading: NSLayoutConstraint!
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //self.navigationItem.backBarButtonItem?.isEnabled = true
        imageViewObject.image = image
        
        scrollViewObject.delegate = self
        scrollViewObject.minimumZoomScale = 0.10
        scrollViewObject.maximumZoomScale = 3.0
        
        // A zoom scale of one indicates that the content is displayed at normal size
        // A zoom scale less than one shows the content zoomed out
        // A zoom scale greater than one shows the content zoomed in
        scrollViewObject.zoomScale = 0.5 //0.25 //0.5
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //print("viewWillAppear")
        centerImage()
        
    }
    /*
     override func viewWillLayoutSubviews() {
     super.viewWillLayoutSubviews()
     updateMinZoomScaleForSize(view.bounds.size)
     }
     */
    
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        
        let widthScale = size.width / imageViewObject.bounds.width
        let heightScale = size.height / imageViewObject.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollViewObject.minimumZoomScale = minScale
        scrollViewObject.zoomScale = minScale
    }
    
    @IBAction func tapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        
        print("minimumZoomScale: \(scrollViewObject.minimumZoomScale)")
        print("scrollViewObject.zoomScale: \(scrollViewObject.zoomScale)")
        
        if scrollViewObject.zoomScale > scrollViewObject.minimumZoomScale {
            scrollViewObject.setZoomScale(scrollViewObject.minimumZoomScale, animated: true)
        } else {
            scrollViewObject.setZoomScale(scrollViewObject.maximumZoomScale, animated: true)
        }

        print("scrollViewObject.zoomScale: \(scrollViewObject.zoomScale)")

        scrollViewObject.layoutIfNeeded()
        //view.layoutIfNeeded()

    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        //print ("isZomming: \(scrollView.isZooming)")
        
        return imageViewObject
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        //let size = view.bounds.size
        print("scrollViewDidZoom")
        //centerImage()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        centerImage()
        
    }
    
    private func centerImage() {
        
        
        let size = scrollViewObject.bounds.size
        print("height: \(size.height), width: \(size.width)")
        print("imageViewObject.frame.height: \(imageViewObject.frame.height), imageViewObject.frame.width: \(imageViewObject.frame.width)")
        
        print("scrollView.frame.height: \(scrollViewObject.frame.height), scrollView.frame.width: \(scrollViewObject.frame.width)")
        
        if #available(iOS 11.0, *) {
            print("safe area, top: \(view.safeAreaInsets.top), bottom: \(view.safeAreaInsets.bottom)")
        } else {
            // Fallback on earlier versions
        }
        
        //let yOffset = max(0, (size.height - imageViewObject.frame.height) / 2)
        //let yOffset = max(0, (size.height - 64 - imageViewObject.frame.height) / 2)
        let yOffset = max(0, (size.height - imageViewObject.frame.height) / 2) - 64
        //let yOffset = max(0, (size.height - 64 - scrollView.frame.height) / 2)
        imageViewTop.constant = yOffset + 64
        imageViewBottom.constant = yOffset
        
        let xOffset = max(0, (size.width - imageViewObject.frame.width) / 2)
        //let xOffset = max(0, (size.width - scrollView.frame.width) / 2)
        
        imageViewLeading.constant = xOffset
        imageViewTrailing.constant = xOffset
        view.layoutIfNeeded()
        
        print("yOffset: \(yOffset), xOffset: \(xOffset)")
        
        print("zoom scale: \(scrollViewObject.zoomScale)" )
        
    }
}

