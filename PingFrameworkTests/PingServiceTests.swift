//
//  PingServiceTests.swift
//  PingFrameworkTests
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import XCTest
@testable import PingFrameworkTest

final class PingServiceTests: XCTestCase {
    var networkManager: NetworkManager!
    var session: MockURLSession!
    var pingService: PingService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        session = MockURLSession()
        session.mDelegate = self
        networkManager = NetworkManager(session: session)
        pingService = PingService()
        pingService.reqUrlPath = "https://sample.hosts.com"
    }

    override func tearDownWithError() throws {
        pingService = nil
        networkManager = nil
        session.mDelegate = nil
        session = nil
        try super.tearDownWithError()
    }

    func testMakeRequest() {
        // Act
        let request = pingService.makeRequest()
        
        // Assert
        XCTAssertNotNil(request)
    }

    func testFetchCompletion() throws {
        // Arrange
        let bundle = Bundle(for: NetworkManager.self)
        guard let mockResponseFileUrl = bundle.url(forResource: "PingHosts", withExtension: "json"),
              let data = try? Data(contentsOf: mockResponseFileUrl) else {
            XCTFail("Expected success, but got failure")
            return
        }
        
        let model = try JSONDecoder().decode(Hosts.self, from: data)
                
        let expectation = XCTestExpectation(description: "Completion handler invoked")
        
        // Act
        pingService.fetch { (result: Result<Hosts, NetworkError>) in
            // Assert
            switch result {
            case .success(let data):
                XCTAssertEqual(
                    data.map { $0.name },
                    model.map { $0.name }
                )
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

extension PingServiceTests: MockURLSessionDelegate {
    func resourceName(for path: String, httpMethod: String) -> String {
        return "PingHosts"
    }
}
