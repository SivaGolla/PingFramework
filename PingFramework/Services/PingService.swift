//
//  PingService.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation
import Combine

class PingService: ServiceProviding {
    
    // MARK: - Properties
    var reqUrlPath: String = ""
    
    /// Url Query parameters for the request.
    // var urlSearchParams: RequestQueryParametersProviding?
            
    var bodyParams: Encodable?
    
    // MARK: - ServiceProviding Methods
    
    /// Constructs a Request object based on the search parameters.
    /// - Returns: A Request object, or nil if the URL path cannot be constructed.
    func makeRequest() -> Request {
        
        let body: Data? = nil
        
        // Create and return a Request object with the constructed URL path.
        let request = Request(
            path: reqUrlPath,
            method: .get,
            contentType: "application/json",
            headerParams: nil,
            type: .ping,
            body: body
        )
        return request
    }
    
    /// Executes a network request and returns the result.
    /// - Parameter completion: A closure to handle the result of the network request.
    /// - Note: This method is generic and can handle any Decodable type.
    func fetch<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        
        // Construct the request using makeRequest().
        let request = makeRequest()
        
        // Execute the request using NetworkManager.
        NetworkManager(session: UserSession.activeSession).execute(request: request) { result in
            DispatchQueue.main.async {
                // Call the completion handler with the result of the request.
                completion(result)
            }
        }
    }
    
    /// Executes a network request and returns the result.
    /// - Note: This method is generic and can handle any Decodable type.
    ///
    @MainActor
    func fetch<T>() async throws -> T where T : Decodable {
        
        // Construct the request using makeRequest().
        let request = makeRequest()
        
        // Execute the request using NetworkManager.
        return try await NetworkManager(session: UserSession.activeSession).execute(request: request)
    }
    
    /// Fetches a resource from the network using a constructed request and returns a publisher that emits a decoded result.
    ///
    /// This method constructs the network request using the `makeRequest()` method and uses the `NetworkManager`
    /// to execute it. The response is expected to be of type `T` which conforms to the `Decodable` protocol.
    ///
    /// - Returns: An `AnyPublisher` that emits a decoded object of type `T` if the request is successful, or a `NetworkError` if it fails.
    /// - Note: The decoding will occur based on the type `T` that conforms to the `Decodable` protocol.
    func fetch<T>() -> AnyPublisher<T, NetworkError> where T : Decodable  {
        // Construct the request using makeRequest().
        let request = makeRequest()
        return NetworkManager(session: UserSession.activeSession).execute(request: request)
    }
}
