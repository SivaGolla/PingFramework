//
//  MockNetworkManagerTests.swift
//  PingFrameworkTests
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import XCTest
// @testable import PingFramework_Dev

final class MockNetworkManagerTests: XCTestCase {

    var networkManager: NetworkManager!
    var session: MockURLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        session = MockURLSession()
        session.mDelegate = self
        networkManager = NetworkManager(session: session)
    }

    override func tearDownWithError() throws {
        session.mDelegate = nil
        session = nil
        networkManager = nil
        try super.tearDownWithError()
    }

    func testExecuteRequestForURL() {
        
        guard let url = URL(string: "https://mockurl") else {
            fatalError("URL can't be empty")
        }
        
        let request = Request(path: "https://mockurl",
                              method: .get,
                              contentType: "application/json",
                              headerParams: nil,
                              type: .weatherForecast,
                              body: nil)
        
        networkManager.execute(request: request, completion: { [weak self](result: (Result<WeatherResponse, NetworkError>)) in
            if let sessionUrl = self?.session.lastURL {
                XCTAssert(sessionUrl == url)
            }
        })
        
    }
    
    func testExecuteDataTaskWithResumeCalled() {
        
        let dataTask = MockURLSessionDataTask()
        session.mockDataTask = dataTask
        
        let request = Request(path: "https://mockurl",
                              method: .get,
                              contentType: "application/json",
                              headerParams: nil,
                              type: .weatherForecast,
                              body: nil)
        
        networkManager.execute(request: request, completion: { (result: (Result<[WeatherResponse], NetworkError>)) in
            
        })
        
        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func testExecuteAsyncRequestForURL() async throws {
        
        guard let url = URL(string: "https://mockurl") else {
            fatalError("URL can't be empty")
        }
        
        let request = Request(path: "https://mockurl",
                              method: .get,
                              contentType: "application/json",
                              headerParams: nil,
                              type: .weatherForecast,
                              body: nil)
        
        let result: WeatherResponse = try await networkManager.execute(request: request)
        
        if let sessionUrl = session.lastURL {
            XCTAssert(sessionUrl == url)
        }
        
        XCTAssertNotNil(result)
    }

}

extension MockNetworkManagerTests: MockURLSessionDelegate {
    func resourceName(for path: String, httpMethod: String) -> String {
        return "WeatherResponseData"
    }
}
