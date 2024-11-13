//
//  UserSession.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

/// A utility class that manages user session configurations, including caching and network session settings.
class UserSession {
    
    /// A shared URLSession configured for network requests with custom settings.
    /// - The session is configured to ignore local cache data and not use a URL cache.
    /// - The session also has a timeout interval of 30 seconds for both requests and resources.
    static var activeSession: URLSession = {
        // Create a default URL session configuration.
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        
        // Set the cache policy to ignore any local cache data.
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        // Disable URL caching entirely.
        config.urlCache = nil
        
        // Set the timeout interval for individual requests to 30 seconds.
        config.timeoutIntervalForRequest = 30
        
        // Set the timeout interval for loading an entire resource to 30 seconds.
        config.timeoutIntervalForResource = 30
        
        // Return a URLSession instance with the configured settings.
        return URLSession(configuration: config)
    }()
}
