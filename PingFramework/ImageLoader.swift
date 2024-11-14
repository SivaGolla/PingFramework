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
    
    /// Loads an image from a specified URL string asynchronously, using a cache to store previously loaded images.
    ///
    /// - Parameter urlString: The URL string of the image to be loaded.
    /// - Returns: An optional `UIImage` if the image was successfully loaded; otherwise, `nil`.
    /// - Throws:
    ///   - `URLError` if the URL is invalid or there was an error in downloading the image data.
    /// - Note: This function checks if the image is already cached and, if so, returns it immediately. If not, it
    ///   downloads the image, caches it for future use, and then returns it.
    func loadImage(from urlString: String) async throws -> UIImage? {
        
        // Check if the image is already cached.
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            // If the image is cached, return it immediately.
            return cachedImage
        }
        
        // Ensure the URL string is valid and can be converted to a URL object.
        guard let url = URL(string: urlString) else {
            // Throw an error if the URL is invalid.
            throw URLError(.badURL)
        }
        
        // Start a network request to fetch the image data.
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Check if the data is valid and can be converted into an image.
        guard let image = UIImage(data: data) else {
            return nil  // Return nil if image creation fails
        }
        
        // Cache the image for future use.
        self.cache.setObject(image, forKey: urlString as NSString)
        
        // Return the loaded image.
        return image
    }
}
