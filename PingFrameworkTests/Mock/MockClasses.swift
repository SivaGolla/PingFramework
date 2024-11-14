//
//  MockClasses.swift
//  PingFramework-Dev
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import Foundation
import UIKit

class UserSession {
    static var activeSession: URLSessionProtocol = MockURLSession()
}

extension HostEntry {
    static func == (lhs: HostEntry, rhs: HostEntry) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url && lhs.imageUrl == rhs.imageUrl
    }
}

// Mock PingService
class MockPingService: PingService {
    var shouldReturnError = false
    var mockHosts: [HostEntry] = []
    
    override func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        if shouldReturnError {
            completion(.failure(.invalidUrl))  // Simulate a failure
        } else {
            completion(.success(mockHosts as! T))  // Return mock hosts
        }
    }
}

// Mock LatencyAnalyzer
class MockLatencyAnalyzer: LatencyAnalyzer {
    var mockLatency: Double = 0.1
    var shouldReturnError = false
    
    override func execute(host: String, completion: @escaping (Result<Double, Error>) -> Void) {
        if shouldReturnError {
            completion(.failure(NetworkError.noData))  // Simulate error
        } else {
            completion(.success(mockLatency))  // Return mock latency
        }
    }
}

// Mock ImageLoader
class MockImageLoader: ImageLoader {
    var mockImage: UIImage?
    var shouldReturnError = false
    
    override func loadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        if shouldReturnError {
            completion(nil)  // Simulate image loading failure
        } else {
            completion(mockImage)  // Return mock image
        }
    }
}
