//
//  ServerRowViewModel.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation
import UIKit

class ServerRowViewModel {
    
    /// <#Description#>
    private var model : ServerRowModel
    
    /// <#Description#>
    var title: Observable<String?>?
    
    /// <#Description#>
    var description: Observable<String?>?
    
    /// <#Description#>
    var image: Observable<UIImage?>?

    /// <#Description#>
    private var imageProvicerService = ImageProviderService()
    
    /// <#Description#>
    private(set) var isLoading : Observable<Bool> = Observable(false)
    
    /// Default Initializer for `ServerRowViewModel`
    ///
    /// - Parameter model: a `ServerRowModel` modal object
    init(withRow model : ServerRowModel) {
        self.model = model
        self.title = Observable<String?>(model.title)
        self.description = Observable<String?>(model.description)
        self.image = Observable(nil)
    }
    
    
    /// Load image and cache in memory if you need to cache image in disk
    /// you need pass `true` to `shouldCacheImage` parameter
    /// - Parameters:
    ///   - shouldCacheImage: a boolean indicator should cache image or not
    ///   - completion: callback closure. fire when loadImage is complete wheter have `image` or `error`
    func loadImage(shouldCacheImage : Bool = true, _ completion :@escaping (UIImage?, Error?) -> ()) {
        
        if let url = model.imageHref {
            
            imageProvicerService.load(url: url,cache:shouldCacheImage) {[unowned self] ( result ) in
                
                switch result.result {
                case .success(let image):
                    self.image?.value = image
                    completion(image,nil)
                case .failure(let error):
                    completion(nil,error)
                }
                
            }
        }else {        
            completion(nil,nil)
        }
        
    }
    
}
