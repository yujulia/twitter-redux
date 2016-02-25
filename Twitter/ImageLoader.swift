//
//  ImageLoader.swift
//  Twitter
//
//  Created by Julia Yu on 2/23/16.
//  Copyright © 2016 Julia Yu. All rights reserved.
//

import Foundation
import AFNetworking

class ImageLoader {
    
    // -------------------------------------- 
    
    static func loadImage(url: NSURL, imageview: UIImageView) {
        ImageLoader.loadImage(url, imageview: imageview, success:nil, failure:nil)
    }
    
    // --------------------------------------
    
    static func loadImage(
        url: NSURL,
        imageview: UIImageView,
        success: (()-> Void)?,
        failure: ((error: NSError)-> Void)?
        ) {
        
        let urlRequest = NSURLRequest(URL: url)

        imageview.setImageWithURLRequest(
            urlRequest,
            placeholderImage: nil,
            success: { (req: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                imageview.image = image
                success?()
            }) { (req: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                failure?(error: error)
            }
    }
}