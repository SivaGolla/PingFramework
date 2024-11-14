//
//  PingManagerTests.swift
//  PingFrameworkTests
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import XCTest
@testable import PingFrameworkTest

final class PingManagerTests: XCTestCase {

    var pingManager: PingManager!
    var mockPingService: MockPingService!
    var mockLatencyAnalyzer: MockLatencyAnalyzer!
    var mockImageLoader: MockImageLoader!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPingService = MockPingService()
        mockLatencyAnalyzer = MockLatencyAnalyzer()
        mockImageLoader = MockImageLoader()
        
        pingManager = PingManager()
        pingManager.pingService = mockPingService
        pingManager.latencyAnalyzer = mockLatencyAnalyzer
        pingManager.imageLoader = mockImageLoader
    }

    override func tearDownWithError() throws {
        pingManager = nil
        mockPingService = nil
        mockLatencyAnalyzer = nil
        mockImageLoader = nil
        
        try super.tearDownWithError()
    }

    // Test when fetch is successful and latencies and images are valid.
    func testStartPinging_Success() {
        // Arrange
        let mockHost = HostEntry(name: "Test Host", url: "http://example.com", imageUrl: "http://example.com/image.jpg")
        mockPingService.mockHosts = [mockHost]
        mockImageLoader.mockImage = UIImage()
        
        // Act
        let expectation = self.expectation(description: "Completion handler invoked")
        
        pingManager.startPinging(urlString: "http://example.com") { results in
            // Assert
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.name, "Test Host")
            XCTAssertEqual(results.first?.averageLatency, 0.1)
            XCTAssertNotNil(results.first?.image)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Test when fetch fails
    func testStartPinging_FetchFailure() {
        // Arrange
        mockPingService.shouldReturnError = true
        
        // Act
        let expectation = self.expectation(description: "Completion handler invoked")
        
        pingManager.startPinging(urlString: "http://example.com") { results in
            // Assert
            XCTAssertEqual(results.count, 0)  // Expect empty results on failure
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Test when latency measurement fails
    func testStartPinging_LatencyFailure() {
        // Arrange
        let mockHost = HostEntry(name: "Test Host", url: "http://example.com", imageUrl: "http://example.com/image.jpg")
        mockPingService.mockHosts = [mockHost]
        mockLatencyAnalyzer.shouldReturnError = true
        
        // Act
        let expectation = self.expectation(description: "Completion handler invoked")
        
        pingManager.startPinging(urlString: "http://example.com") { results in
            // Assert
            XCTAssertEqual(results.count, 1)
            XCTAssertEqual(results.first?.averageLatency, nil)  // Latency should be nil on failure
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Test when image loading fails
    func testStartPinging_ImageLoadingFailure() {
        // Arrange
        let mockHost = HostEntry(name: "Test Host", url: "http://example.com", imageUrl: "http://example.com/image.jpg")
        mockPingService.mockHosts = [mockHost]
        mockImageLoader.shouldReturnError = true
        
        // Act
        let expectation = self.expectation(description: "Completion handler invoked")
        
        pingManager.startPinging(urlString: "http://example.com") { results in
            // Assert
            XCTAssertEqual(results.count, 1)
            XCTAssertNil(results.first?.image)  // Image should be nil on failure
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}
