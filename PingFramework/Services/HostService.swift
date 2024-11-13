//
//  HostService.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

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
    func ping<T>(completion: @escaping (Result<T, NetworkError>) -> Void) where T : Decodable {
        
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
}
