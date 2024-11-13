//
//  HostViewModel.swift
//  NetworkLatencyAnalyzer
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import Foundation
import PingFramework

class HostViewModel {
    let host: PingResult?

    var hostName: String {
        host?.name ?? ""
    }
    
    var averageLatency: String {
        if let latency = host?.averageLatency {
            return "\(latency) ms"
        }
        
        return ""
    }
    
    init(hostInfo: PingResult?) {
        host = hostInfo
    }    
}
