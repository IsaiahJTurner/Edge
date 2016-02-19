//
//  Constants.swift
//  Edge
//
//  Created by Isaiah Turner on 2/17/16.
//  Copyright © 2016 Isaiah Turner. All rights reserved.
//


struct Constants {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
        static let DEVICE_IS_SIMULATOR = true
        static let endpoint = "http://localhost:3002/api/v1.0"
    #else
        static let endpoint = "http://edge-development.herokuapp.com/api/v1.0"
        static let DEVICE_IS_SIMULATOR = false
    #endif
}