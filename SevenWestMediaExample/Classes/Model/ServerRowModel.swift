//
//  ServerRowModel.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

/// Row Modal
struct ServerRowModel : Codable {
    
    /// repesent value of title in ServerRow JSON
    let title: String?
    
    /// <#Description#>
    let description: String?
    
    /// <#Description#>
    let imageHref: URL?
    
}
