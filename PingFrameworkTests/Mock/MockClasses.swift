//
//  MockClasses.swift
//  PingFramework-Dev
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import Foundation

class UserSession {
    static var activeSession: URLSessionProtocol = MockURLSession()
}

