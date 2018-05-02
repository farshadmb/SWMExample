//
//  ServerDataModel.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

/// A Data Model class
struct ServerDataModel : Codable {
    
    /// title value is String which represent title in Server model
    let title: String
    
    /// represent of rows of `ServerRowModel`
    let rows: [ServerRowModel]
    
}
