//
//  HostListViewModel.swift
//  NetworkLatencyAnalyzer
//
//  Created by Venkata Sivannarayana Golla on 13/11/24.
//

import SwiftUI
import PingFramework

typealias PingResult = PingFramework.PingResult
typealias PingManager = PingFramework.PingManager

class HostListViewModel: ObservableObject {
    
    @Published var latencies: [PingResult] = []
    @State var loading: Bool = false
    
    private let pinger = PingManager()

    private let host = Host(name: "ThousandEyes",
                            address: "https://gist.githubusercontent.com/anonymous/290132e587b77155eebe44630fcd12cb/raw/777e85227d0c1c16e466475bb438e0807900155c/sk_hosts")
    

    func loadLatencies() {
        
        loading = true
        // Using PingFramework to fetch latency for a host's address
        pinger.startPinging(urlString: host.address) { [weak self] results in
            DispatchQueue.main.async {
                self?.latencies = results
                self?.loading = false
            }
        }
    }
}
