//
//  ImageLoader.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import UIKit
import Foundation

/// A class responsible for loading images from a URL and caching them for future use.
class ImageLoader {
    
    /// A cache to store images once they are loaded, to avoid re-fetching them from the network.
    private var cache = NSCache<NSString, UIImage>()
    
    /**
     Loads an image from a provided URL string. If the image is already cached, it will return the cached image. Otherwise, it will fetch the image from the network and cache it for future use.
     
     - Parameter urlString: The URL string of the image to be loaded.
     - Parameter completion: A closure that is called once the image is loaded or if an error occurs. The closure receives the image, or `nil` if the image couldn't be loaded.
     */
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        // Check if the image is already cached.
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            // If the image is cached, return it immediately.
            completion(cachedImage)
            return
        }
        
        // Ensure the URL string is valid and can be converted to a URL object.
        guard let url = URL(string: urlString) else {
            // If the URL is invalid, return nil.
            completion(nil)
            return
        }
        
        // Start a network request to fetch the image data.
        URLSession.shared.dataTask(with: url) { data, _, _ in
            // Check if the data is valid and can be converted into an image.
            guard let data = data, let image = UIImage(data: data) else {
                // If there was an issue with the data or image, return nil.
                completion(nil)
                return
            }
            
            // Cache the image for future use.
            self.cache.setObject(image, forKey: urlString as NSString)
            
            // Ensure the completion handler is called on the main thread, as UI updates must be done on the main thread.
            DispatchQueue.main.async {
                // Return the loaded image via the completion handler.
                completion(image)
            }
        }.resume()  // Start the network request.
    }
}
