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
        guard let hostUrl = URL(string: host) else {
            completion(.failure(NetworkError.invalidUrl))  // Return error if the URL is invalid
            return
        }
        
        // Loop to send multiple pings based on the `pingCount` constant.
        for _ in 0..<Constants.pingCount {
            
            dispatchGroup.enter()  // Enter the DispatchGroup for each async request
            
            let startTime = Date()  // Record the start time for latency calculation
            
            // Perform an HTTP request to measure the round-trip time.
            URLSession.shared.dataTask(with: hostUrl) { [weak self] _, response, error in
                
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
}

