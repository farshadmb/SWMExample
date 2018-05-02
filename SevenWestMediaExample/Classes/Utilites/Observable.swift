//
//  Observable.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

/// <#Description#>
final class Observable<Type> {
    
    typealias Observer = (_ newValue : Type,_ oldValue :Type?) -> ()
    private var observers : [UUID : Observer] = [:]
    
    
    var value : Type {
        didSet{
            
            observers.values.forEach { (observer) in
                observer(value,oldValue)
            }
            
        }
    }
    
    deinit {
        removeAllObservers()
    }
    
    init(_ value : Type){
        self.value = value
    }
    
    @discardableResult
    func observe(_ observer : @escaping Observer) -> Disposable {
        
        let id = UUID()
        observers[id] = observer
        observer(value, nil)
        
        let disposable = Disposable { [weak self] in
            self?.observers[id] = nil
        }
        
        return disposable
        
    }
    
    public func removeAllObservers() {
        observers.removeAll()
    }
    
}

