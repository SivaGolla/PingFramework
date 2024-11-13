//
//  PingResult.swift
//  PingFramework
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import UIKit

@objcMembers
public class PingResult: NSObject, Identifiable {
    public var id = UUID()
    public let name: String
    public var averageLatency: Double?
    public var image: UIImage?
    
    init(name: String, averageLatency: Double? = nil, image: UIImage? = nil) {
        self.name = name
        self.averageLatency = averageLatency
        self.image = image
    }
}
