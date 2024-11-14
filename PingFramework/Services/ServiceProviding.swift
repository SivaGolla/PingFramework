//
//  ServiceProviding.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

/// A protocol defining methods and properties for services that make network requests and handle responses.
protocol ServiceProviding {
    
    /// Creates a `Request` object based on the service's requirements.
    /// - Returns: An `Request` object that encapsulates the details for the network request.
    /// - This method should be implemented to build and return a `Request` object that includes the path, method, headers, and other necessary details.
    func makeRequest() -> Request
    
    /// Fetches data from the network and decodes it into a model of type `T`.
    /// - Parameter completion: A closure that will be called with the result of the network request. It returns a `Result` type that either contains the decoded object of type `T` or a `NetworkError`.
    /// - This method handles making the request, processing the response, and decoding the data into the specified type.
    /// - Note: The `T` type parameter must conform to the `Decodable` protocol to allow JSON decoding.
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T: Decodable
    
    
    /// Fetches data from the network and decodes it into a model of type `T`.
    /// - Returns: A decoded model of type `T`
    /// - This method handles making the request, processing the response, and decoding the data into the specified type.
    /// - Note: The `T` type parameter must conform to the `Decodable` protocol to allow JSON decoding.
    func fetch<T>() async throws -> T where T : Decodable
}
