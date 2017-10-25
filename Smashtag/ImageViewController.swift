//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Lily Song on 2017-10-21.
//  Copyright © 2017 Lily Song. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    // Model
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { //if we're on screen
                fetchImage()        //then fetch image
            }
        }
    }
    var aspectRatio: Double?        //image aspect ratio
    
    // Private Implementation
    @IBOutlet weak var spinning: UIActivityIndicatorView!
    
    private func fetchImage() {
        if let url = imageURL {
            spinning.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                if let imageData = urlContents, url == self?.imageURL {
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    // View Controller Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {   //we're about to appear on screen, so if needed,
            fetchImage()    //fetch image
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollingView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)              //fix elevated bottom scrolling
    }
    
    // User Interface
    @IBOutlet weak var scrollingView: UIScrollView! {
        didSet {
            //to zoom we have to handle viewForZooming(in scrollView:)
            scrollingView.delegate = self
            scrollingView.minimumZoomScale = 0.25
            scrollingView.maximumZoomScale = 2
            
            imageView.frame.size = resize(with: aspectRatio)
            scrollingView.contentSize = imageView.frame.size
            
            scrollingView.addSubview(imageView)
        }
    }
    
    fileprivate var imageView = UIImageView()
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            guard newValue != nil else {
                return
            }
            imageView.image = newValue
            
            imageView.frame.size = resize(with: aspectRatio)
            scrollingView?.contentSize = imageView.frame.size
            
            spinning?.stopAnimating()
        }
    }
    
    private func resize(with aspectRatio: Double?) -> CGSize {
        
        var svSize = scrollingView.contentSize
        let scrollAspectRatio = (scrollingView.bounds.width / scrollingView.bounds.height)
        
        guard aspectRatio != nil else {
            return CGSize()
        }
        
        if aspectRatio! >= Double(scrollAspectRatio) {      //sets heights equal
            svSize.height = scrollingView.bounds.height
            svSize.width = CGFloat(aspectRatio!) * svSize.height
        } else {                                            //set widths equal
            svSize.width = scrollingView.bounds.width
            svSize.height = CGFloat(1/aspectRatio!) * svSize.width
        }
        
        return svSize
    }

}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
