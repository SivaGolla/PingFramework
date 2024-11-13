//
//  URLSessionProtocol.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

/// A protocol abstraction for URLSession, allowing for better testability by enabling mocking of network requests.
protocol URLSessionProtocol {
    
    /// Typealias for the completion handler used in data tasks.
    /// - Parameters:
    ///   - data: The data returned by the server.
    ///   - response: The response returned by the server.
    ///   - error: An error object that indicates why the request failed, or nil if the request was successful.
    ///
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    
    /// Creates a data task with the given request and completion handler.
    /// - Parameters:
    ///   - request: The URLRequest object that provides the request details.
    ///   - completionHandler: The completion handler to call when the load request is complete.
    /// - Returns: A URLSessionDataTaskProtocol that can be used to start the request.
    ///
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

/// Extension to conform URLSession to the URLSessionProtocol, enabling the use of URLSession in a testable way.
extension URLSession: URLSessionProtocol {
    
    /// Creates a data task with the given request and completion handler.
    /// - Parameters:
    ///   - request: The URLRequest object that provides the request details.
    ///   - completionHandler: The completion handler to call when the load request is complete.
    /// - Returns: A URLSessionDataTaskProtocol that can be used to start the request.
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        // Create a URLSessionDataTask and return it as a URLSessionDataTaskProtocol.
        let dataTask = dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
        return dataTask
    }
}

/// A protocol abstraction for URLSessionDataTask, allowing for better testability.
protocol URLSessionDataTaskProtocol {
    /// Resumes the task, if it is suspended.
    func resume()
}

/// Extension to conform URLSessionDataTask to the URLSessionDataTaskProtocol, allowing it to be used within the URLSessionProtocol abstraction.
extension URLSessionDataTask: URLSessionDataTaskProtocol {}
