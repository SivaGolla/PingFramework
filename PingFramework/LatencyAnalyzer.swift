//
//  LatencyAnalyzer.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

/// `LatencyAnalyzer` is responsible for measuring the latency of network requests to a given host.
///
/// This class uses `URLSession` to send multiple requests to a specified host and calculates the average latency
/// based on the round-trip time of the requests. It uses a `DispatchGroup` to synchronize the async tasks and notify when all pings are complete.
class LatencyAnalyzer {
    
    /// The `DispatchGroup` used to synchronize the multiple network requests (pings) for latency measurement.
    let dispatchGroup = DispatchGroup()
    var urlSession = UserSession.activeSession
    
    /// Validates and ensures that the provided URL string has a valid scheme (`http://` or `https://`).
    /// If the URL string doesn't have a scheme, `https://` is automatically prepended.
    ///
    /// - Parameter urlString: The string representation of the URL to be validated and created.
    /// - Returns: A `URL` object if the string is valid, or `nil` if the string cannot be converted to a valid URL.
    func validateAndCreateURL(from urlString: String) -> URL? {
        var validURLString = urlString

        // Check if the URL has a valid scheme
        if !validURLString.lowercased().hasPrefix("http://") && !validURLString.lowercased().hasPrefix("https://") {
            validURLString = "https://" + validURLString
        }

        return URL(string: validURLString)
    }

    /**
     Executes latency measurement by sending multiple requests to the specified host.
     
     - Parameters:
        - host: The URL string of the host to ping.
        - completion: A closure that is called with the result of the latency measurement.
            - `.success(Double)`: The average latency in seconds.
            - `.failure(Error)`: An error, such as invalid URL or no data received.
     
     - This method performs the following steps:
        1. Validates the URL of the host.
        2. Sends multiple requests to the host (based on `Constants.pingCount`).
        3. Measures the round-trip time for each request and stores the latency.
        4. Once all requests complete, it calculates the average latency and passes it to the completion handler.
     */
    func execute(host: String, completion: @escaping (Result<Double, Error>) -> Void) {
        var latencies: [TimeInterval] = []  // Store individual latencies for all pings
        
        // Validate the host URL.
        guard let hostUrl = validateAndCreateURL(from: host) else {
            completion(.failure(NetworkError.invalidUrl))  // Return error if the URL is invalid
            return
        }
        
        let urlRequest = URLRequest(url: hostUrl)
        
        // Loop to send multiple pings based on the `pingCount` constant.
        for _ in 0..<Constants.pingCount {
            
            dispatchGroup.enter()  // Enter the DispatchGroup for each async request
            
            let startTime = Date()  // Record the start time for latency calculation
            
            // Perform an HTTP request to measure the round-trip time.
            urlSession.dataTask(with: urlRequest) { [weak self] _, response, error in
                
                defer {
                    self?.dispatchGroup.leave()  // Ensure leaving the DispatchGroup once the task is complete
                }
                
                // Ignore the result if there's an error or no valid response.
                guard error == nil, response != nil else {
                    return
                }
                
                // Measure the latency as the time difference between sending the request and receiving the response.
                let latency = Date().timeIntervalSince(startTime)
                latencies.append(latency)  // Append the latency to the latencies array
            }.resume()  // Start the network request
        }
        
        // Once all pings are completed, notify the main queue with the result.
        dispatchGroup.notify(queue: .main) {
            
            // If no valid latencies are recorded, return an error.
            guard !latencies.isEmpty else {
                completion(.failure(NetworkError.noData))  // Return error if no valid latencies are collected
                return
            }
            
            // Calculate the average latency by summing all latencies and dividing by the count.
            let averageLatency = latencies.reduce(0, +) / Double(latencies.count)
            completion(.success(averageLatency))  // Return the average latency
        }
    }
    
    /// Measures the average latency for a specified host by sending multiple HTTP requests asynchronously.
    ///
    /// - Parameter host: The URL string of the host to be pinged.
    /// - Returns: The average latency in seconds as a `Double`.
    /// - Throws:
    ///   - `NetworkError.invalidUrl` if the provided host string cannot be converted to a valid URL.
    ///   - `NetworkError.noData` if no successful latencies were recorded.
    /// - Note: This function sends a number of HTTP requests (defined by `Constants.pingCount`) to the specified host
    ///   and calculates the average round-trip time. Each request's response time is measured, and errors from individual
    ///   requests are ignored to ensure that intermittent failures do not prevent successful completion.

    func execute(host: String) async throws -> Double {
        var latencies: [TimeInterval] = []  // Store individual latencies for all pings

        // Validate the host URL.
        guard let hostUrl = URL(string: host) else {
            throw NetworkError.invalidUrl  // Throw an error if the URL is invalid
        }

        let urlRequest = URLRequest(url: hostUrl)
        
        // Loop to send multiple pings based on the `pingCount` constant.
        for _ in 0..<Constants.pingCount {
            // Record the start time for latency calculation
            let startTime = Date()
            
            do {
                // Perform an HTTP request to measure the round-trip time
                let (_, response) = try await urlSession.data(from: hostUrl, delegate: nil)
                
                // Measure the latency as the time difference between sending the request and receiving the response.
                let latency = Date().timeIntervalSince(startTime)
                latencies.append(latency)  // Append the latency to the latencies array
                
            } catch {
                // Ignore failed ping requests, proceed with next iteration
                continue
            }
        }
        
        // If no valid latencies are recorded, throw an error.
        guard !latencies.isEmpty else {
            throw NetworkError.noData  // Throw error if no valid latencies are collected
        }

        // Calculate the average latency by summing all latencies and dividing by the count.
        let averageLatency = latencies.reduce(0, +) / Double(latencies.count)
        return averageLatency  // Return the average latency
    }

}

