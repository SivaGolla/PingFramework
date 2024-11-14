//
//  LatencyAnalyzerTests.swift
//  PingFrameworkTests
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import XCTest
@testable import PingFrameworkTest

final class LatencyAnalyzerTests: XCTestCase {
    
    var latencyAnalyzer: LatencyAnalyzer!
    var mockURLSession: MockURLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        latencyAnalyzer = LatencyAnalyzer()
        mockURLSession = MockURLSession()
        
        // Inject the mock URLSession into LatencyAnalyzer
        latencyAnalyzer.urlSession = mockURLSession
    }
    
    override func tearDownWithError() throws {
        latencyAnalyzer = nil
        mockURLSession = nil
        try super.tearDownWithError()
    }
    
    // Test successful latency measurement
    func testExecute_Success() {
        // Arrange
        let host = "http://example.com"
        mockURLSession.mockData = Data()
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: host)!, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockURLSession.mockError = nil
        
        // Override latencyAnalyzer's execute method to simulate latency calculation
        let expectation = self.expectation(description: "Completion handler invoked")
        
        latencyAnalyzer.execute(host: host) { result in
            // Assert
            switch result {
            case .success(let latency):
                XCTAssertTrue(latency > 0)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Test failure due to no response or error in the network call
    func testExecute_NetworkError() {
        // Arrange
        let host = "http://example.com"
        mockURLSession.mockData = nil
        mockURLSession.mockResponse = nil
        mockURLSession.mockError = .internalServerError
        
        // Act
        let expectation = self.expectation(description: "Completion handler invoked")
        
        latencyAnalyzer.execute(host: host) { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                XCTAssertEqual(error as? NetworkError, NetworkError.noData)  // Ensure error is no data received
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
