//
//  Disposable.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation


/// Array of `Disposable`
public typealias Disposal = [Disposable]

/// Disposable class
public final class Disposable {
    
    private let dispose: () -> ()
    
    init(_ dispose: @escaping () -> ()) {
        self.dispose = dispose
    }
    
    deinit {
        dispose()
    }
    
    public func add(to disposal: inout Disposal) {
        disposal.append(self)
    }
}
