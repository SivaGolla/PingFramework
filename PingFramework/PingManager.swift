//
//  PingManager.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import UIKit

/// `PingManager` is responsible for handling pinging operations, analyzing latency, and loading images for a list of hosts.
///
/// This class coordinates the fetching of host data, pings each host to measure latency, and fetches images associated with each host.
/// It manages the network operations asynchronously using `DispatchGroup` to synchronize the tasks and return the results once all operations complete.
@objc
public class PingManager: NSObject {
    
    /// The service responsible for making network requests to fetch hosts.
    let pingService = PingService()
    
    /// The analyzer used to measure the latency for each host.
    let latencyAnalyzer = LatencyAnalyzer()
    
    /// The loader used to fetch images associated with the hosts.
    let imageLoader = ImageLoader()
    
    /// Initializes a new instance of `PingManager`.
    ///
    /// The initializer sets up the necessary components (`PingService`, `LatencyAnalyzer`, and `ImageLoader`) to be used for pinging hosts,
    /// analyzing latency, and loading images.
    @objc public override init() {}
    
    /**
     Starts pinging a given URL, analyzes the latency for each host, and loads the associated images.
     
     - Parameters:
        - urlString: The URL string of the target to fetch hosts from.
        - completion: A closure that is called when all hosts have been pinged, with an array of `PingResult` objects containing the results.
     
     - This method performs the following steps:
        1. Fetches a list of hosts from the provided URL.
        2. Pings each host and measures latency.
        3. Loads an image for each host.
        4. Once all tasks are completed, the results are passed to the provided completion handler.
     */
    @objc public func startPinging(urlString: String, completion: @escaping ([PingResult]) -> Void) {
        
        // Set the request URL for the PingService.
        pingService.reqUrlPath = urlString
        
        // Fetch the list of hosts using the PingService.
        pingService.fetch() { (result: Result<Hosts, NetworkError>) in
            switch result {
            case .success(let hosts):
                var results: [PingResult] = []
                let dispatchGroup = DispatchGroup()  // To synchronize async tasks
                
                // Iterate over each host to ping and load image.
                for host in hosts {
                    
                    dispatchGroup.enter()  // Enter the DispatchGroup for each async task
                    
                    // Ping each host and measure latency.
                    self.latencyAnalyzer.execute(host: host.url) { pingResult in
                        let result = PingResult(name: host.name, averageLatency: nil, image: nil)
                        
                        // If latency measurement is successful, store the latency.
                        if case let .success(latency) = pingResult {
                            result.averageLatency = latency
                        }
                        
                        // Load the image for the host.
                        self.imageLoader.loadImage(from: host.imageUrl) { image in
                            result.image = image  // Set the image result
                            results.append(result)  // Add result to the final array
                            dispatchGroup.leave()  // Leave the DispatchGroup once the task is done
                        }
                    }
                }
                
                // Notify once all pinging and image loading tasks are complete.
                dispatchGroup.notify(queue: .main) {
                    // Return the final results through the completion handler.
                    completion(results)
                }
                
            case .failure(let error):
                // Print error and return an empty array if fetching hosts failed.
                print("Failed to fetch hosts: \(error)")
                completion([])  // Return an empty array in case of error
            }
        }
    }
}

