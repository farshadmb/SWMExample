//
//  ServerDataModel.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

struct ServerDataModel : Codable {
    
    let title: String
    let rows: [ServerRowModel] 
    
}
