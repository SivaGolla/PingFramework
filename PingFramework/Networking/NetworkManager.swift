//
//  NetworkManager.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation
import Combine

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
    
    /// Executes a network request and decodes the response into the specified `Decodable` type.
    ///
    /// - Parameter request: A `Request` object containing the necessary details for the network request (e.g., path, HTTP method, headers, and body).
    /// - Returns: The decoded response of type `T`, which must conform to the `Decodable` protocol.
    /// - Throws:
    ///   - `NetworkError.invalidUrl`: If the request URL cannot be encoded or constructed.
    ///   - `NetworkError.parsingError`: If the response data cannot be decoded into the expected type.
    ///   - `NetworkError.internalServerError`: If the server returns a status code between 500 and 599.
    ///   - `NetworkError.badRequest`: If the response status code indicates a bad request or another error.
    ///
    func execute<T: Decodable>(request: Request) async throws -> T {
        
        // Encode the request path to ensure it is a valid URL.
        guard let path = request.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                let url = URL(string: path) else {
            throw NetworkError.invalidUrl
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
                
        let (data, response) = try await activeSession.data(for: urlRequest, delegate: nil)
        
        // Ensure the response is an HTTPURLResponse.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badRequest
        }
        
        // Handle the response based on the HTTP status code.
        switch httpResponse.statusCode {
        case 200...300:
            // Successful response range.
            
            // Attempt to decode the response data into the expected type.
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                return result
                
            } catch let error as NSError {
                // Print error details and return a parsing error.
                print(error.debugDescription)
                throw NetworkError.parsingError
            }
            
        case 500...599:
            // Server error range.
            throw NetworkError.internalServerError
            
        default:
            // Handle other status codes as bad requests.
            throw NetworkError.badRequest
        }
    }
}

extension NetworkManager {
    
    /// Executes a network request and decodes the response into the specified `Decodable` type using Combine framework.
    ///
    /// - Parameter request: A `Request` object containing the details for the network request (URL path, HTTP method, headers, and body).
    /// - Returns: A publisher that outputs a decoded object of type `T` on success, or a `NetworkError` on failure.
    /// - Throws:
    ///   - `NetworkError.invalidUrl`: If the request URL is invalid or cannot be encoded.
    ///   - `NetworkError.internalServerError`: If the server returns a status code between 500 and 599.
    ///   - `NetworkError.badRequest`: If the response status code is outside the 200...300 range or another error occurs.
    ///   - `NetworkError.parsingError`: If the response data cannot be decoded into the expected type.
    ///
    func execute<T: Decodable>(request: Request) -> AnyPublisher<T, NetworkError> {
        
        // Encode the request path to ensure it is a valid URL.
        guard let path = request.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: path) else {
            
            return Fail(error: NetworkError.invalidUrl)
                .eraseToAnyPublisher()
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
        
        // Use the session to create a data task publisher.
        return activeSession.dataTaskAPublisher(for: urlRequest)
            .tryMap { (data: Data, response: URLResponse) in
                
                // Ensure the response is an HTTPURLResponse to get access to the status code.
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.internalServerError
                }
                
                switch httpResponse.statusCode {
                case 200...300:
                    // Successful response range.
                    return data
                    
                case 500...599:
                    // Server error range.
                    throw NetworkError.internalServerError
                    
                default:
                    // Handle other status codes as bad requests.
                    throw NetworkError.badRequest
                }
            }
            // Decode the response data into the expected Decodable type `T`.
            .decode(type: T.self, decoder: JSONDecoder())
        
            // Ensure that the result is delivered on the main thread.
            .receive(on: DispatchQueue.main)
        
            // Map any errors into a custom NetworkError.
            .mapError { error -> NetworkError in
                
                switch error {
                case let serviceError as NetworkError:
                    return serviceError
                default:
                    return .parsingError
                }
            }
        
            // Return the publisher with an erased type (AnyPublisher) to hide the implementation details.
            .eraseToAnyPublisher()
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
