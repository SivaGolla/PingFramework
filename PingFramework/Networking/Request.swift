//
//  Request.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

/// HTTP request method types.
/// - `get`: Represents the GET HTTP method, used to retrieve data from the server.
/// - `post`: Represents the POST HTTP method, used to send data to the server.
enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}

/// Defines the supported request types for different API endpoints.
/// - `weatherForecast`: A request to retrieve Weather Forecast of a location.
/// - Add more cases as required to support other request types.
///
enum RequestType {
    case ping
}

/// Protocol defining the necessary components for making an HTTP request.
protocol Requesting {
    /// The path or endpoint of the API request (e.g., "/api/v1/cats").
    var path: String { get set }
    
    /// The HTTP method to be used (e.g., GET, POST).
    var method: RequestMethod { get set }
    
    /// The content type of the request (e.g., "application/json").
    var contentType: String { get set }
    
    /// Optional headers to include in the request (e.g., authorization tokens).
    var headerParams: [String: String]? { get set }
    
    /// The type of the request, defining the specific API call being made.
    var type: RequestType { get set }
    
    /// The body of the request, typically used with POST or PUT methods.
    var body: Data? { get set }
}

/// A struct representing the base structure of an HTTP request, conforming to the `Requesting` protocol.
struct Request: Requesting {
    /// The path or endpoint of the API request.
    var path: String
    
    /// The HTTP method to be used.
    var method: RequestMethod
    
    /// The content type of the request.
    var contentType: String
    
    /// Optional headers to include in the request.
    var headerParams: [String: String]?
    
    /// The type of the request, defining the specific API call being made.
    var type: RequestType
    
    /// The body of the request, typically used with POST or PUT methods.
    var body: Data?
}
