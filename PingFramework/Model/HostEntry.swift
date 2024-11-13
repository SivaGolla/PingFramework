//
//  HostEntry.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import Foundation

public class HostEntry: NSObject, Codable {
    let name: String
    let url: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
        case imageUrl = "icon"
    }
}

typealias Hosts = [HostEntry]
