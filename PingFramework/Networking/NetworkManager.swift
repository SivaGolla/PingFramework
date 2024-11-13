//
//  NetworkManager.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

/// A class responsible for managing network requests and handling responses.
class NetworkManager: NSObject {
    
    /// The URLSession instance used to perform network operations, conforming to the `URLSessionProtocol` for testability.
    private let activeSession: URLSessionProtocol
    
    /// Initializes a `NetworkManager` instance with a specified URLSessionProtocol.
    ///
    /// - Parameter session: An object conforming to `URLSessionProtocol` to handle network tasks.
    init(session: URLSessionProtocol) {
        activeSession = session
    }
    
    /// Executes a network request and processes the response.
    ///
    /// - Parameters:
    ///   - request: The `Request` object containing details for the network request.
    ///   - completion: A closure to be executed once the network request completes. It returns a `Result` type with either a decoded object of type `T` or a `NetworkError`.
    /// - Returns: The URLSessionDataTaskProtocol instance representing the network task. This can be used to manage the task.
    ///
    @discardableResult
    func execute<T: Decodable>(request: Request, completion: @escaping (Result<T, NetworkError>) -> Void) -> URLSessionDataTaskProtocol? {
        
        // Encode the request path to ensure it is a valid URL.
        guard let path = request.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: path) else {
            completion(.failure(.invalidUrl))
            return nil
        }
        
        // Create a URLRequest with the encoded URL.
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.addValue(request.contentType, forHTTPHeaderField: "Content-Type")
        
        // Add additional header parameters if provided.
        if let headerParams = request.headerParams {
            for (key, value) in headerParams {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set the body of the request if it is a POST request and the body is provided.
        if request.method == .post, let body = request.body {
            urlRequest.httpBody = body
        }
                
        // Create a data task to perform the request.
        let task = activeSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            // Ensure the response is an HTTPURLResponse.
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.badRequest))
                return
            }
                        
            // Handle the response based on the HTTP status code.
            switch httpResponse.statusCode {
            case 200...300:
                // Successful response range.
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // Attempt to decode the response data into the expected type.
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch let error as NSError {
                    // Print error details and return a parsing error.
                    print(error.debugDescription)
                    completion(.failure(.parsingError))
                }
                
            case 500...599:
                // Server error range.
                completion(.failure(.internalServerError))
                
            default:
                // Handle other status codes as bad requests.
                completion(.failure(.badRequest))
            }
        })
        
        // Start the network task.
        task.resume()
        return task
    }
}
    
// Extension to conform to URLSessionDelegate for cache management.
extension NetworkManager: URLSessionDelegate {
    
    /// Prevents caching of responses by URLSession.
    ///
    /// - Parameters:
    ///   - session: The URLSession instance handling the request.
    ///   - dataTask: The URLSessionDataTask instance performing the request.
    ///   - proposedResponse: The proposed CachedURLResponse that would be used.
    ///   - completionHandler: A closure to be called with the final CachedURLResponse or nil if caching should be ignored.
    ///
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        // This application does not use NSURLCache for disk or memory caching, so return nil to prevent caching.
        completionHandler(nil)
    }
}
