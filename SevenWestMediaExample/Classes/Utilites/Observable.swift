//
//  Observable.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

/// Generic Obserable Class
final class Observable<Type> {
    
    typealias Observer = (_ newValue : Type,_ oldValue :Type?) -> ()
    private var observers : [UUID : Observer] = [:]
    
    
    var value : Type {
        didSet{
            // fire all observer when newValue has been setted
            observers.values.forEach { (observer) in
                observer(value,oldValue)
            }
            
        }
    }
    
    deinit {
        // cleaup observer from strong reference
        removeAllObservers()
    }
    
    /// Init Designed for Observer Class
    ///
    /// - Parameter value: a value of Generic `Type`
    init(_ value : Type){
        self.value = value
    }

    
    /// observe and call back when a new value set
    ///
    /// - Parameter observer: callback closure, called when a new value is set
    /// - Returns: Disposable Object for dispose
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
    
    /// cleanup all observers
    public func removeAllObservers() {
        observers.removeAll()
    }
    
}

